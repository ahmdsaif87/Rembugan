from fastapi import Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.models import User, Project
from app.models.social import Showcase
from app.models.collaboration import SavedItem


class SavedService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def list_saved(self, user_id: str, page: int, limit: int) -> tuple[list[dict], int]:
        result = await self.session.execute(
            select(func.count(SavedItem.id)).where(SavedItem.user_id == user_id)
        )
        total = result.scalar() or 0

        result = await self.session.execute(
            select(SavedItem)
            .where(SavedItem.user_id == user_id)
            .order_by(SavedItem.created_at.desc())
            .offset((page - 1) * limit)
            .limit(limit)
        )
        saved_items = result.scalars().all()

        project_ids = [s.project_id for s in saved_items if s.project_id]
        showcase_ids = [s.showcase_id for s in saved_items if s.showcase_id]

        projects_map = {}
        if project_ids:
            result = await self.session.execute(select(Project).where(Project.id.in_(project_ids)))
            projects = result.scalars().all()
            owner_ids = list(set(p.owner_id for p in projects))
            owners_map = {}
            if owner_ids:
                result = await self.session.execute(select(User).where(User.id.in_(owner_ids)))
                owners_map = {u.id: u for u in result.scalars().all()}
            for p in projects:
                owner = owners_map.get(p.owner_id)
                projects_map[p.id] = {
                    "id": p.id,
                    "title": p.title,
                    "description": p.description,
                    "required_skills": p.required_skills,
                    "status": p.status,
                    "owner_name": owner.full_name if owner else None,
                    "member_count": len(p.members) if p.members else 0,
                }

        showcases_map = {}
        if showcase_ids:
            result = await self.session.execute(select(Showcase).where(Showcase.id.in_(showcase_ids)))
            showcases = result.scalars().all()
            author_ids = list(set(s.author_id for s in showcases))
            authors_map = {}
            if author_ids:
                result = await self.session.execute(select(User).where(User.id.in_(author_ids)))
                authors_map = {u.id: u for u in result.scalars().all()}
            for s in showcases:
                author = authors_map.get(s.author_id)
                showcases_map[s.id] = {
                    "id": s.id,
                    "content": s.content,
                    "media_urls": s.media_urls,
                    "author_name": author.full_name if author else None,
                }

        result_data = []
        for item in saved_items:
            entry = {
                "id": item.id,
                "type": "project" if item.project_id else "showcase",
                "created_at": item.created_at.isoformat(),
            }
            if item.project_id and item.project_id in projects_map:
                entry["project"] = projects_map[item.project_id]
            if item.showcase_id and item.showcase_id in showcases_map:
                entry["showcase"] = showcases_map[item.showcase_id]
            result_data.append(entry)
        return result_data, total

    async def save_project(self, user_id: str, project_id: int) -> dict:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Project tidak ditemukan")
        result = await self.session.execute(
            select(SavedItem).where(
                SavedItem.user_id == user_id,
                SavedItem.project_id == project_id,
            )
        )
        existing = result.scalar_one_or_none()
        if existing:
            raise HTTPException(status_code=400, detail="Project sudah disimpan")
        saved = SavedItem(user_id=user_id, project_id=project_id)
        self.session.add(saved)
        await self.session.commit()
        await self.session.refresh(saved)
        return {"id": saved.id, "type": "project"}

    async def save_showcase(self, user_id: str, showcase_id: str) -> dict:
        result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        result = await self.session.execute(
            select(SavedItem).where(
                SavedItem.user_id == user_id,
                SavedItem.showcase_id == showcase_id,
            )
        )
        existing = result.scalar_one_or_none()
        if existing:
            raise HTTPException(status_code=400, detail="Showcase sudah disimpan")
        saved = SavedItem(user_id=user_id, showcase_id=showcase_id)
        self.session.add(saved)
        await self.session.commit()
        await self.session.refresh(saved)
        return {"id": saved.id, "type": "showcase"}

    async def check_saved(self, user_id: str, project_id: int | None = None, showcase_id: str | None = None) -> dict:
        stmt = select(SavedItem).where(SavedItem.user_id == user_id)
        if project_id is not None:
            stmt = stmt.where(SavedItem.project_id == project_id)
        if showcase_id is not None:
            stmt = stmt.where(SavedItem.showcase_id == showcase_id)
        result = await self.session.execute(stmt)
        saved = result.scalar_one_or_none()
        return {"is_saved": saved is not None, "saved_id": saved.id if saved else None}

    async def unsave(self, item_id: int, user_id: str):
        result = await self.session.execute(
            select(SavedItem).where(SavedItem.id == item_id, SavedItem.user_id == user_id)
        )
        saved = result.scalar_one_or_none()
        if not saved:
            raise HTTPException(status_code=404, detail="Item tidak ditemukan")
        await self.session.delete(saved)
        await self.session.commit()

    async def unsave_showcase(self, showcase_id: str, user_id: str):
        result = await self.session.execute(
            select(SavedItem).where(
                SavedItem.user_id == user_id,
                SavedItem.showcase_id == showcase_id,
            )
        )
        saved = result.scalar_one_or_none()
        if not saved:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan di saved")
        await self.session.delete(saved)
        await self.session.commit()
