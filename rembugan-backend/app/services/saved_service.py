from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db


class SavedService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def list_saved(self, user_id: str, page: int, limit: int) -> tuple[list[dict], int]:
        total = await self.db.saveditem.count(where={"user_id": user_id})
        saved = await self.db.saveditem.find_many(
            where={"user_id": user_id},
            include={
                "project": {"include": {"owner": True, "members": True}},
                "showcase": {"include": {"author": True}},
            },
            order={"created_at": "desc"},
            skip=(page - 1) * limit,
            take=limit,
        )
        result = []
        for item in saved:
            entry = {
                "id": item.id,
                "type": "project" if item.project else "showcase",
                "created_at": item.created_at.isoformat(),
            }
            if item.project:
                entry["project"] = {
                    "id": item.project.id,
                    "title": item.project.title,
                    "description": item.project.description,
                    "required_skills": item.project.required_skills,
                    "status": item.project.status,
                    "owner_name": item.project.owner.full_name if item.project.owner else None,
                    "member_count": len(item.project.members) if item.project.members else 0,
                }
            if item.showcase:
                entry["showcase"] = {
                    "id": item.showcase.id,
                    "content": item.showcase.content,
                    "media_urls": item.showcase.media_urls,
                    "author_name": item.showcase.author.full_name if item.showcase.author else None,
                }
            result.append(entry)
        return result, total

    async def save_project(self, user_id: str, project_id: int) -> dict:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Project tidak ditemukan")
        existing = await self.db.saveditem.find_first(
            where={"user_id": user_id, "project_id": project_id}
        )
        if existing:
            raise HTTPException(status_code=400, detail="Project sudah disimpan")
        saved = await self.db.saveditem.create(
            data={"user_id": user_id, "project_id": project_id}
        )
        return {"id": saved.id, "type": "project"}

    async def save_showcase(self, user_id: str, showcase_id: str) -> dict:
        showcase = await self.db.showcase.find_unique(where={"id": showcase_id})
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        existing = await self.db.saveditem.find_first(
            where={"user_id": user_id, "showcase_id": showcase_id}
        )
        if existing:
            raise HTTPException(status_code=400, detail="Showcase sudah disimpan")
        saved = await self.db.saveditem.create(
            data={"user_id": user_id, "showcase_id": showcase_id}
        )
        return {"id": saved.id, "type": "showcase"}

    async def check_saved(self, user_id: str, project_id: int | None = None, showcase_id: str | None = None) -> dict:
        where = {"user_id": user_id}
        if project_id is not None:
            where["project_id"] = project_id
        if showcase_id is not None:
            where["showcase_id"] = showcase_id
        saved = await self.db.saveditem.find_first(where=where)
        return {"is_saved": saved is not None, "saved_id": saved.id if saved else None}

    async def unsave(self, item_id: int, user_id: str):
        saved = await self.db.saveditem.find_first(where={"id": item_id, "user_id": user_id})
        if not saved:
            raise HTTPException(status_code=404, detail="Item tidak ditemukan")
        await self.db.saveditem.delete(where={"id": item_id})

    async def unsave_showcase(self, showcase_id: str, user_id: str):
        saved = await self.db.saveditem.find_first(
            where={"user_id": user_id, "showcase_id": showcase_id}
        )
        if not saved:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan di saved")
        await self.db.saveditem.delete(where={"id": saved.id})
