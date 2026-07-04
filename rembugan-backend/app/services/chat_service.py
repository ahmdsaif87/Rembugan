import re
from datetime import datetime, timezone
from fastapi import Depends, HTTPException, UploadFile
from prisma import Prisma
from app.core.database import get_db
from app.core.dates import tz_iso
from app.core.constants import CHAT_HISTORY_MAX, NOTIF_GROUP_TAG, NOTIF_CHAT
from app.services.chat_manager import manager
from app.services.notification import notify
from app.services.storage import upload_image_to_cloudinary
from app.core.tasks import fire_and_forget
from app.core.logger import get_logger

logger = get_logger(__name__)


class ChatService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def upload_dm_file(self, uid: str, receiver_id: str, file: UploadFile) -> dict:
        if uid == receiver_id:
            raise HTTPException(status_code=400, detail="Tidak bisa kirim file ke diri sendiri")

        content = await file.read()
        size = len(content)
        if size > 50 * 1024 * 1024:
            raise HTTPException(status_code=413, detail="File terlalu besar (maks 50MB)")

        url = await upload_image_to_cloudinary(content, folder_name="rembugan_chat_files")

        sender = await self.db.user.find_unique(where={"id": uid})

        msg = await self.db.message.create(data={
            "content": "",
            "type": "file",
            "sender_id": uid,
            "receiver_id": receiver_id,
            "attachment_url": url,
            "attachment_name": file.filename,
            "attachment_size": size,
        })

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
            self.db, receiver_id, NOTIF_CHAT,
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

    async def get_my_rooms(self, uid: str) -> list[dict]:
        read_states = await self.db.roomread.find_many(where={"user_id": uid})
        read_map = {r.room_id: r.last_read_at for r in read_states}

        messages = await self.db.message.find_many(
            where={
                "project_id": None,
                "OR": [
                    {"sender_id": uid},
                    {"receiver_id": uid},
                ]
            },
            include={"sender": True, "receiver": True},
            order={"created_at": "desc"},
        )

        seen = set()
        rooms = []
        for m in messages:
            if not m.receiver_id:
                continue
            other_id = m.receiver_id if m.sender_id == uid else m.sender_id
            other = m.receiver if m.sender_id == uid else m.sender
            sorted_ids = "_".join(sorted([uid, other_id]))
            room_id = f"dm_{sorted_ids}"

            if room_id not in seen:
                seen.add(room_id)
                last_read = read_map.get(room_id)
                unread_where = {"sender_id": other_id, "receiver_id": uid}
                if last_read:
                    unread_where["created_at"] = {"gt": last_read}
                unread = await self.db.message.count(where=unread_where)

                rooms.append({
                    "room_id": room_id,
                    "type": "dm",
                    "name": other.full_name if other else "User",
                    "other_user_id": other_id,
                    "photo_url": other.photo_url if other else None,
                    "last_message": m.content[:80] if m.content else "",
                    "last_time": tz_iso(m.created_at),
                    "unread": unread,
                    "is_online": manager.is_online(other_id),
                })

        return rooms

    async def mark_room_read(self, uid: str, room_id: str) -> None:
        await self.db.roomread.upsert(
            where={"user_id_room_id": {"user_id": uid, "room_id": room_id}},
            data={
                "create": {"user_id": uid, "room_id": room_id},
                "update": {"last_read_at": datetime.now(timezone.utc)},
            },
        )

    async def get_chat_history(self, uid: str, room_id: str, limit: int = 50) -> dict:
        other_user_online = None

        if room_id.isdigit():
            messages = await self.db.message.find_many(
                where={"project_id": int(room_id)},
                include={"sender": True},
                order={"created_at": "asc"},
                take=limit,
            )
        else:
            parts = room_id.split("_")
            if len(parts) >= 3:
                user1, user2 = parts[1], parts[2]
                other_id = user2 if user1 == uid else user1
                other_user_online = manager.is_online(other_id)
                messages = await self.db.message.find_many(
                    where={
                        "OR": [
                            {"sender_id": user1, "receiver_id": user2},
                            {"sender_id": user2, "receiver_id": user1},
                        ]
                    },
                    include={"sender": True},
                    order={"created_at": "asc"},
                    take=limit,
                )
            else:
                raise HTTPException(status_code=400, detail="Format room_id tidak valid.")

        result = []
        for msg in messages:
            result.append({
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

        data = {"room_id": room_id, "messages": result}
        if other_user_online is not None:
            data["other_user_online"] = other_user_online
        return data

    async def _handle_mentions(self, sender_id: str, project_id: int, preview: str, mentions: list[str]):
        try:
            sender = await self.db.user.find_unique(where={"id": sender_id})
            sender_name = sender.full_name if sender else "Seseorang"
            project = await self.db.project.find_unique(where={"id": project_id})
            project_title = project.title if project else "Proyek"
            mentioned_users = await self.db.user.find_many(
                where={"full_name": {"in": mentions, "mode": "insensitive"}}
            )
            mentioned_map = {u.full_name.lower(): u for u in mentioned_users}
            for mention in mentions:
                mentioned_user = mentioned_map.get(mention.lower())
                if mentioned_user and mentioned_user.id != sender_id:
                    await notify(
                        self.db, mentioned_user.id, NOTIF_GROUP_TAG,
                        f"Anda dimention di grup '{project_title}'",
                        f"{sender_name} men-tag anda: {preview}",
                        f"/workspace/{project_id}",
                    )
        except Exception as e:
            logger.error(f"Gagal proses mention: {e}")

    async def _broadcast_feed_group(self, sender_id: str, project_id: int, room_id: str, preview: str, now: datetime):
        try:
            members = await self.db.projectmember.find_many(where={"project_id": project_id})
            feed = {
                "event": "feed_message",
                "room_id": room_id,
                "type": "group",
                "sender_id": sender_id,
                "text": preview,
                "timestamp": now.isoformat(),
            }
            for m in members:
                if m.user_id != sender_id:
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
        except Exception as e:
            logger.error(f"Gagal broadcast feed DM: {e}")

    async def _handle_dm_notification(self, sender_id: str, receiver_id: str, preview: str, room_id: str):
        try:
            sender = await self.db.user.find_unique(where={"id": sender_id})
            sender_name = sender.full_name if sender else "Seseorang"
            await notify(
                self.db, receiver_id, NOTIF_CHAT,
                f"Pesan baru dari {sender_name}",
                preview,
                f"/chat/{room_id}",
            )
        except Exception as e:
            logger.error(f"Gagal proses notif DM: {e}")
