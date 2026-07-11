import os
from datetime import datetime, timezone
from urllib.parse import quote
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import ROLE_KETUA
from app.core.logger import get_logger

logger = get_logger(__name__)

APP_URL = os.getenv("APP_URL", "http://localhost:3000")


class PostsService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def create_post(self, user_id: str, data: dict) -> dict:
        type_ = data.get("type")
        if type_ == "post":
            if not data.get("content"):
                raise HTTPException(status_code=400, detail="Content wajib diisi untuk postingan")
            showcase = await self.db.showcase.create(
                data={
                    "author_id": user_id,
                    "content": data["content"],
                    "media_urls": data.get("media_urls") or [],
                    "tags": data.get("tags") or [],
                },
                include={"author": True},
            )
            return {
                "type": "post",
                "id": showcase.id,
                "content": showcase.content,
                "media_urls": showcase.media_urls,
                "tags": showcase.tags,
                "author_name": showcase.author.full_name,
                "created_at": showcase.created_at.isoformat(),
            }
        elif type_ == "offer":
            if not data.get("title") or not data.get("description") or not data.get("required_skills"):
                raise HTTPException(
                    status_code=400,
                    detail="title, description, dan required_skills wajib diisi untuk tawaran",
                )
            project = await self.db.project.create(
                data={
                    "owner_id": user_id,
                    "title": data["title"],
                    "description": data["description"],
                    "required_skills": data["required_skills"],
                    "category": data.get("category"),
                    "deadline": data.get("deadline"),
                    "total_slots": data.get("total_slots"),
                },
                include={"owner": True},
            )
            await self.db.projectmember.create(
                data={"project_id": project.id, "user_id": user_id, "role": ROLE_KETUA}
            )
            return {
                "type": "offer",
                "id": project.id,
                "title": project.title,
                "description": project.description,
                "category": project.category,
                "required_skills": project.required_skills,
                "total_slots": project.total_slots,
                "deadline": project.deadline.isoformat() if project.deadline else None,
                "owner_name": project.owner.full_name,
                "created_at": project.created_at.isoformat(),
            }
        raise HTTPException(status_code=400, detail="Tipe postingan tidak valid")

    async def share_post(self, user_id: str, post_id: str, post_type: str, friend_ids: list[str]) -> dict:
        if not friend_ids:
            raise HTTPException(status_code=400, detail="Pilih minimal satu teman untuk dibagikan.")

        sender = await self.db.user.find_unique(where={"id": user_id})
        if not sender:
            raise HTTPException(status_code=404, detail="User tidak ditemukan.")
        sender_name = sender.full_name

        if post_type == "post":
            showcase = await self.db.showcase.find_unique(where={"id": post_id})
            if not showcase:
                raise HTTPException(status_code=404, detail="Postingan tidak ditemukan.")
            preview = showcase.content[:100]
            share_link = f"{APP_URL}/s/{post_id}"
            share_text = f"Cek postingan ini di Rembugan: {share_link}"
        elif post_type == "offer":
            project = await self.db.project.find_unique(where={"id": int(post_id)})
            if not project:
                raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
            preview = project.title
            share_link = f"{APP_URL}/p/{post_id}"
            share_text = f'Cek proyek "{project.title}" di Rembugan: {share_link}'
        else:
            raise HTTPException(status_code=400, detail="Tipe postingan tidak valid.")

        verified_friends = await self.db.connection.find_many(
            where={
                "status": "accepted",
                "OR": [
                    {"sender_id": user_id, "receiver_id": {"in": friend_ids}},
                    {"sender_id": {"in": friend_ids}, "receiver_id": user_id},
                ],
            }
        )
        connected_ids = set()
        for c in verified_friends:
            other = c.receiver_id if c.sender_id == user_id else c.sender_id
            connected_ids.add(other)

        if not connected_ids:
            raise HTTPException(status_code=400, detail="Tidak ada teman yang valid untuk dibagikan.")

        now = datetime.now(timezone.utc)
        share_title = title[:80] if post_type == "offer" else preview[:80]
        dm_content = f"📌 {sender_name} membagikan {('postingan' if post_type == 'post' else 'proyek')}:\n\n{preview}\n\n🔗 {share_link}"

        sent_to = []
        message_data = []
        for friend_id in connected_ids:
            message_data.append({
                "content": dm_content,
                "type": "share",
                "sender_id": user_id,
                "receiver_id": friend_id,
                "attachment_url": share_link,
                "attachment_name": share_title,
            })
        if message_data:
            await self.db.message.create_many(data=message_data)

            try:
                from app.services.chat_manager import manager
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
