from fastapi import Depends, HTTPException
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.models.user import User
from app.models.skill import Skill, UserSkill


class ProfileServiceSQL:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def search(self, query: str) -> list[dict]:
        stmt = (
            select(User)
            .where(
                or_(
                    User.full_name.ilike(f"%{query}%"),
                    User.nim.ilike(f"%{query}%"),
                )
            )
            .order_by(User.full_name.asc())
            .limit(20)
        )
        result = await self.session.execute(stmt)
        users = result.scalars().all()

        return [
            {
                "id": u.id,
                "full_name": u.full_name,
                "nim": u.nim,
                "bio": u.bio,
                "photo_url": u.photo_url,
                "major": u.major,
            }
            for u in users
        ]

    async def get_profile(self, target_user_id: str) -> dict | None:
        stmt = (
            select(User)
            .where(User.id == target_user_id)
        )
        result = await self.session.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            return None

        return {
            "id": user.id,
            "full_name": user.full_name,
            "handle": user.handle,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "major": user.major,
            "skills": [s.skill.name for s in user.skills] if user.skills else [],
        }
