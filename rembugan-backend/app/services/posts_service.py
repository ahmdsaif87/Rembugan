from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import ROLE_KETUA


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
                    "interest": data.get("interest"),
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
