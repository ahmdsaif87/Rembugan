import os
from datetime import datetime, timezone
from urllib.parse import quote
from fastapi import Depends, HTTPException
from sqlalchemy import select, or_, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import ROLE_KETUA
from app.core.logger import get_logger
from app.models import User, Project, ProjectMember
from app.models.social import Showcase, Connection
from app.models.chat import Message

logger = get_logger(__name__)

APP_URL = os.getenv("APP_URL", "http://localhost:3000")


class PostsService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def create_post(self, user_id: str, data: dict) -> dict:
        type_ = data.get("type")
        if type_ == "post":
            if not data.get("content"):
                raise HTTPException(status_code=400, detail="Content wajib diisi untuk postingan")
            showcase = Showcase(
                author_id=user_id,
                content=data["content"],
                media_urls=data.get("media_urls") or [],
                tags=data.get("tags") or [],
            )
            self.session.add(showcase)
            await self.session.commit()
            await self.session.refresh(showcase)

            result = await self.session.execute(select(User).where(User.id == user_id))
            author = result.scalar_one_or_none()

            return {
                "type": "post",
                "id": showcase.id,
                "content": showcase.content,
                "media_urls": showcase.media_urls,
                "tags": showcase.tags,
                "author_name": author.full_name if author else None,
                "created_at": showcase.created_at.isoformat(),
            }
        elif type_ == "offer":
            if not data.get("title") or not data.get("description") or not data.get("required_skills"):
                raise HTTPException(
                    status_code=400,
                    detail="title, description, dan required_skills wajib diisi untuk tawaran",
                )
            project = Project(
                owner_id=user_id,
                title=data["title"],
                description=data["description"],
                required_skills=data["required_skills"],
                category=data.get("category"),
                deadline=data.get("deadline"),
                total_slots=data.get("total_slots"),
            )
            self.session.add(project)
            await self.session.flush()

            member = ProjectMember(project_id=project.id, user_id=user_id, role=ROLE_KETUA)
            self.session.add(member)
            await self.session.commit()
            await self.session.refresh(project)

            result = await self.session.execute(select(User).where(User.id == user_id))
            owner = result.scalar_one_or_none()

            return {
                "type": "offer",
                "id": project.id,
                "title": project.title,
                "description": project.description,
                "category": project.category,
                "required_skills": project.required_skills,
                "total_slots": project.total_slots,
                "deadline": project.deadline.isoformat() if project.deadline else None,
                "owner_name": owner.full_name if owner else None,
                "created_at": project.created_at.isoformat(),
            }
        raise HTTPException(status_code=400, detail="Tipe postingan tidak valid")

    async def share_post(self, user_id: str, post_id: str, post_type: str, friend_ids: list[str]) -> dict:
        if not friend_ids:
            raise HTTPException(status_code=400, detail="Pilih minimal satu teman untuk dibagikan.")

        result = await self.session.execute(select(User).where(User.id == user_id))
        sender = result.scalar_one_or_none()
        if not sender:
            raise HTTPException(status_code=404, detail="User tidak ditemukan.")
        sender_name = sender.full_name

        if post_type == "post":
            result = await self.session.execute(select(Showcase).where(Showcase.id == post_id))
            showcase = result.scalar_one_or_none()
            if not showcase:
                raise HTTPException(status_code=404, detail="Postingan tidak ditemukan.")
            preview = showcase.content[:100]
            share_link = f"{APP_URL}/s/{post_id}"
            share_text = f"Cek postingan ini di Rembugan: {share_link}"
            title = preview
        elif post_type == "offer":
            result = await self.session.execute(select(Project).where(Project.id == int(post_id)))
            project = result.scalar_one_or_none()
            if not project:
                raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
            preview = project.title
            share_link = f"{APP_URL}/p/{post_id}"
            share_text = f'Cek proyek "{project.title}" di Rembugan: {share_link}'
            title = project.title
        else:
            raise HTTPException(status_code=400, detail="Tipe postingan tidak valid.")

        result = await self.session.execute(
            select(Connection).where(
                Connection.status == "accepted",
                or_(
                    and_(Connection.sender_id == user_id, Connection.receiver_id.in_(friend_ids)),
                    and_(Connection.sender_id.in_(friend_ids), Connection.receiver_id == user_id),
                ),
            )
        )
        verified_friends = result.scalars().all()
        connected_ids = set()
        for c in verified_friends:
            other = c.receiver_id if c.sender_id == user_id else c.sender_id
            connected_ids.add(other)

        if not connected_ids:
            raise HTTPException(status_code=400, detail="Tidak ada teman yang valid untuk dibagikan.")

        now = datetime.now(timezone.utc)
        share_title = title[:80]
        dm_content = f"📌 {sender_name} membagikan {('postingan' if post_type == 'post' else 'proyek')}:\n\n{preview}\n\n🔗 {share_link}"

        sent_to = []
        for friend_id in connected_ids:
            msg = Message(
                content=dm_content,
                type="share",
                sender_id=user_id,
                receiver_id=friend_id,
                attachment_url=share_link,
                attachment_name=share_title,
            )
            self.session.add(msg)

        await self.session.commit()

        for friend_id in connected_ids:
            try:
                from app.services.chat_manager import manager
                room_id = f"dm_{'_'.join(sorted([user_id, friend_id]))}"
                feed = {
                    "event": "feed_message",
                    "room_id": room_id,
                    "type": "dm",
                    "sender_id": user_id,
                    "text": dm_content[:80],
                    "attachment_url": share_link,
                    "attachment_name": share_title,
                    "attachment_type": post_type,
                    "post_id": post_id,
                    "timestamp": now.isoformat(),
                }
                await manager.send_to_user(friend_id, feed)
                await manager.send_to_user(user_id, feed)
            except Exception as e:
                logger.warning(f"Gagal broadcast share feed ke {friend_id}: {e}")

            sent_to.append(friend_id)

        encoded_text = quote(share_text)

        return {
            "share_link": share_link,
            "whatsapp_url": f"https://api.whatsapp.com/send?text={encoded_text}",
            "telegram_url": f"https://t.me/share/url?url={quote(share_link)}&text={quote(preview)}",
            "sent_to": sent_to,
            "total_sent": len(sent_to),
        }
