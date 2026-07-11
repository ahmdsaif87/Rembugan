import re
from datetime import datetime, timezone
from fastapi import Depends, HTTPException, UploadFile
from sqlalchemy import select, or_, and_, desc, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.dates import tz_iso
from app.core.constants import CHAT_HISTORY_MAX, NOTIF_GROUP_TAG, NOTIF_CHAT
from app.models.user import User
from app.models.chat import Message, RoomRead
from app.models.collaboration import Project, ProjectMember
from app.services.chat_manager import manager
from app.services.notification import notify
from app.services.storage import upload_image_to_cloudinary
from app.core.tasks import fire_and_forget
from app.core.logger import get_logger

logger = get_logger(__name__)


class ChatService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def upload_dm_file(self, uid: str, receiver_id: str, file: UploadFile) -> dict:
        if uid == receiver_id:
            raise HTTPException(status_code=400, detail="Tidak bisa kirim file ke diri sendiri")

        content = await file.read()
        size = len(content)
        if size > 50 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="File terlalu besar (maks 50MB)")

        url = await upload_image_to_cloudinary(content, folder_name="rembugan_chat_files")

        result = await self.session.execute(select(User).where(User.id == uid))
        sender = result.scalar_one_or_none()

        msg = Message(
            content="",
            type="file",
            sender_id=uid,
            receiver_id=receiver_id,
            attachment_url=url,
            attachment_name=file.filename,
            attachment_size=size,
        )
        self.session.add(msg)
        await self.session.commit()
        await self.session.refresh(msg)

        room_id = f"dm_{min(uid, receiver_id)}_{max(uid, receiver_id)}"
        payload = {
            "sender_id": uid,
            "sender_name": sender.full_name if sender else "Seseorang",
            "text": "",
            "type": "file",
            "attachment_url": url,
            "attachment_name": file.filename,
            "attachment_size": size,
            "timestamp": msg.created_at.isoformat(),
        }
        await manager.broadcast(payload, room_id)

        fire_and_forget(
            self._broadcast_feed_dm(uid, receiver_id, room_id, file.filename or "File", msg.created_at),
            "broadcast_feed_dm"
        )

        await notify(
            self.session, receiver_id, NOTIF_CHAT,
            f"File baru dari {sender.full_name if sender else 'Seseorang'}",
            file.filename or "File",
            f"/chat/{room_id}",
        )

        return {
            "id": msg.id,
            "name": file.filename,
            "url": url,
            "size": size,
        }

    async def get_my_rooms(self, uid: str, skip: int = 0, limit: int = 20) -> list[dict]:
        result = await self.session.execute(
            select(RoomRead).where(RoomRead.user_id == uid)
        )
        read_states = result.scalars().all()
        read_map = {r.room_id: r.last_read_at for r in read_states}

        result = await self.session.execute(
            select(Message)
            .where(
                Message.project_id.is_(None),
                or_(
                    Message.sender_id == uid,
                    Message.receiver_id == uid,
                )
            )
            .order_by(desc(Message.created_at))
            .offset(skip)
            .limit(limit * 3)
        )
        messages = result.scalars().all()

        seen = set()
        room_other_pairs = []
        for m in messages:
            if not m.receiver_id:
                continue
            other_id = m.receiver_id if m.sender_id == uid else m.sender_id
            other = m.receiver if m.sender_id == uid else m.sender
            sorted_ids = "_".join(sorted([uid, other_id]))
            room_id = f"dm_{sorted_ids}"
            if room_id not in seen:
                seen.add(room_id)
                room_other_pairs.append((room_id, other_id, other, m))

        unread_by_room = {}
        if room_other_pairs:
            other_ids = [p[1] for p in room_other_pairs]
            result = await self.session.execute(
                select(Message)
                .where(
                    Message.sender_id.in_(other_ids),
                    Message.receiver_id == uid,
                    Message.project_id.is_(None),
                )
                .order_by(desc(Message.created_at))
            )
            unread_msgs = result.scalars().all()
            for msg in unread_msgs:
                rid = f"dm_{'_'.join(sorted([msg.sender_id, uid]))}"
                last_read = read_map.get(rid)
                if last_read is None or (msg.created_at and msg.created_at > last_read):
                    unread_by_room[rid] = unread_by_room.get(rid, 0) + 1

        rooms = []
        for room_id, other_id, other, m in room_other_pairs:
            rooms.append({
                "room_id": room_id,
                "type": "dm",
                "name": other.full_name if other else "User",
                "other_user_id": other_id,
                "photo_url": other.photo_url if other else None,
                "last_message": m.attachment_name if m.type == "share" and m.attachment_name else (m.content[:80] if m.content else ""),
                "last_time": tz_iso(m.created_at),
                "unread": unread_by_room.get(room_id, 0),
                "is_online": manager.is_online(other_id),
            })

        return rooms

    async def mark_room_read(self, uid: str, room_id: str) -> None:
        result = await self.session.execute(
            select(RoomRead).where(
                RoomRead.user_id == uid,
                RoomRead.room_id == room_id,
            )
        )
        room_read = result.scalar_one_or_none()
        if room_read:
            room_read.last_read_at = datetime.now(timezone.utc)
        else:
            room_read = RoomRead(user_id=uid, room_id=room_id, last_read_at=datetime.now(timezone.utc))
            self.session.add(room_read)
        await self.session.commit()

    async def get_chat_history(self, uid: str, room_id: str, limit: int = 50, before_id: int | None = None) -> dict:
        other_user_online = None

        if room_id.isdigit():
            query = (
                select(Message)
                .where(Message.project_id == int(room_id))
                .order_by(desc(Message.id))
                .limit(limit)
            )
            if before_id is not None:
                query = query.where(Message.id < before_id)
            result = await self.session.execute(query)
            messages = result.scalars().all()
            messages.reverse()
        else:
            parts = room_id.split("_")
            if len(parts) >= 3:
                user1, user2 = parts[1], parts[2]
                other_id = user2 if user1 == uid else user1
                other_user_online = manager.is_online(other_id)
                query = (
                    select(Message)
                    .where(
                        or_(
                            and_(Message.sender_id == user1, Message.receiver_id == user2),
                            and_(Message.sender_id == user2, Message.receiver_id == user1),
                        )
                    )
                    .order_by(desc(Message.id))
                    .limit(limit)
                )
                if before_id is not None:
                    query = query.where(Message.id < before_id)
                result = await self.session.execute(query)
                messages = result.scalars().all()
                messages.reverse()
            else:
                raise HTTPException(status_code=400, detail="Format room_id tidak valid.")

        result_data = []
        for msg in messages:
            result_data.append({
                "id": msg.id,
                "content": msg.content,
                "type": msg.type,
                "sender_id": msg.sender_id,
                "sender_name": msg.sender.full_name if msg.sender else None,
                "attachment_url": msg.attachment_url,
                "attachment_name": msg.attachment_name,
                "attachment_size": msg.attachment_size,
                "reply_to_id": msg.reply_to_id,
                "created_at": tz_iso(msg.created_at),
            })

        data = {"room_id": room_id, "messages": result_data}
        if other_user_online is not None:
            data["other_user_online"] = other_user_online
        return data

    async def _handle_mentions(self, sender_id: str, project_id: int, preview: str, mentions: list[str]):
        try:
            result = await self.session.execute(select(User).where(User.id == sender_id))
            sender = result.scalar_one_or_none()
            sender_name = sender.full_name if sender else "Seseorang"

            result = await self.session.execute(select(Project).where(Project.id == project_id))
            project = result.scalar_one_or_none()
            project_title = project.title if project else "Proyek"

            result = await self.session.execute(
                select(User).where(func.lower(User.full_name).in_([m.lower() for m in mentions]))
            )
            mentioned_users = result.scalars().all()
            mentioned_map = {u.full_name.lower(): u for u in mentioned_users}
            for mention in mentions:
                mentioned_user = mentioned_map.get(mention.lower())
                if mentioned_user and mentioned_user.id != sender_id:
                    await notify(
                        self.session, mentioned_user.id, NOTIF_GROUP_TAG,
                        f"Anda dimention di grup '{project_title}'",
                        f"{sender_name} men-tag anda: {preview}",
                        f"/workspace/{project_id}",
                    )
        except Exception as e:
            logger.error(f"Gagal proses mention: {e}")

    async def _broadcast_feed_group(self, sender_id: str, project_id: int, room_id: str, preview: str, now: datetime):
        try:
            result = await self.session.execute(
                select(ProjectMember).where(ProjectMember.project_id == project_id)
            )
            members = result.scalars().all()
            feed = {
                "event": "feed_message",
                "room_id": room_id,
                "type": "group",
                "sender_id": sender_id,
                "text": preview,
                "timestamp": now.isoformat(),
            }
            for m in members:
                await manager.send_to_user(m.user_id, feed)
        except Exception as e:
            logger.error(f"Gagal broadcast feed group: {e}")

    async def _broadcast_feed_dm(self, sender_id: str, receiver_id: str, room_id: str, preview: str, now: datetime):
        try:
            feed = {
                "event": "feed_message",
                "room_id": room_id,
                "type": "dm",
                "sender_id": sender_id,
                "text": preview,
                "timestamp": now.isoformat(),
            }
            await manager.send_to_user(receiver_id, feed)
            await manager.send_to_user(sender_id, feed)
        except Exception as e:
            logger.error(f"Gagal broadcast feed DM: {e}")

    async def _handle_dm_notification(self, sender_id: str, receiver_id: str, preview: str, room_id: str):
        try:
            result = await self.session.execute(select(User).where(User.id == sender_id))
            sender = result.scalar_one_or_none()
            sender_name = sender.full_name if sender else "Seseorang"
            await notify(
                self.session, receiver_id, NOTIF_CHAT,
                f"Pesan baru dari {sender_name}",
                preview,
                f"/chat/{room_id}",
            )
        except Exception as e:
            logger.error(f"Gagal proses notif DM: {e}")
