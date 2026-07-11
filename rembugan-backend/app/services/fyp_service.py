from fastapi import Depends, HTTPException
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import PJ_OPEN
from app.core.logger import get_logger
from app.core.cache import cache
from app.models import User, Project
from app.models.social import Showcase
from app.services.competitions import get_competition_collection

logger = get_logger(__name__)


class FypService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def _get_user_embedding(self, user_id: str):
        import json
        result = await self.session.execute(
            text('SELECT embedding::text FROM "User" WHERE id = :uid'),
            {"uid": user_id},
        )
        row = result.fetchone()
        if row and row[0]:
            return json.loads(row[0])
        return None

    async def get_fyp(self, user_id: str) -> dict:
        cache_key = f"fyp:{user_id}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached

        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        user_embedding = await self._get_user_embedding(user_id)
        user_skill_names = {s.skill.name.lower() for s in (user.skills or [])}
        user_skills_lower = list(user_skill_names)

        # Showcases: pgvector scoring, fallback ke created_at desc
        showcases_data = []
        vec = f'[{",".join(str(x) for x in user_embedding)}]' if user_embedding else None
        rows = None
        if vec:
            result = await self.session.execute(
                text(
                    'SELECT id, content, media_urls, tags, author_id, created_at, '
                    '1 - (embedding <=> :vec::vector) AS match_score '
                    'FROM "Showcase" WHERE author_id != :uid '
                    'AND 1 - (embedding <=> :vec::vector) > 0.15 '
                    'ORDER BY embedding <=> :vec::vector LIMIT 10'
                ),
                {"vec": vec, "uid": user_id},
            )
            rows = result.fetchall()
        if not vec or not rows:
            result = await self.session.execute(
                text(
                    'SELECT id, content, media_urls, tags, author_id, created_at, 0 AS match_score '
                    'FROM "Showcase" WHERE author_id != :uid '
                    'ORDER BY created_at DESC LIMIT 10'
                ),
                {"uid": user_id},
            )
            rows = result.fetchall()
        if rows:
            s_ids = [r[0] for r in rows]
            s_map = {r[0]: r for r in rows}
            result = await self.session.execute(
                select(Showcase).where(Showcase.id.in_(s_ids))
            )
            showcases = result.scalars().all()
            by_id = {s.id: s for s in showcases}

            author_ids = list(set(s.author_id for s in showcases))
            authors_map = {}
            if author_ids:
                result = await self.session.execute(select(User).where(User.id.in_(author_ids)))
                authors_map = {u.id: u for u in result.scalars().all()}

            for sid in s_ids:
                s = by_id.get(sid)
                if not s:
                    continue
                row = s_map[sid]
                author = authors_map.get(s.author_id)
                showcases_data.append({
                    "id": s.id,
                    "type": "showcase",
                    "content": s.content,
                    "media_urls": s.media_urls,
                    "tags": s.tags,
                    "author_name": author.full_name if author else None,
                    "author_photo": author.photo_url if author else None,
                    "likes_count": len(s.likes) if s.likes else 0,
                    "comments_count": len(s.comments) if s.comments else 0,
                    "match_score": int(float(row[6]) * 100),
                    "created_at": s.created_at.isoformat(),
                })

        # Projects: pgvector scoring, fallback ke created_at desc
        projects_data = []
        vec = f'[{",".join(str(x) for x in user_embedding)}]' if user_embedding else None
        rows = None
        if vec:
            result = await self.session.execute(
                text(
                    'SELECT id, title, description, required_skills, owner_id, created_at, '
                    '1 - (embedding <=> :vec::vector) AS match_score '
                    'FROM "Project" WHERE status = :status '
                    'AND 1 - (embedding <=> :vec::vector) > 0.15 '
                    'ORDER BY embedding <=> :vec::vector LIMIT 10'
                ),
                {"vec": vec, "status": PJ_OPEN},
            )
            rows = result.fetchall()
        if not vec or not rows:
            result = await self.session.execute(
                text(
                    'SELECT id, title, description, required_skills, owner_id, created_at, 0 AS match_score '
                    'FROM "Project" WHERE status = :status '
                    'ORDER BY created_at DESC LIMIT 10'
                ),
                {"status": PJ_OPEN},
            )
            rows = result.fetchall()
        if rows:
            p_ids = [r[0] for r in rows]
            p_map = {r[0]: r for r in rows}
            result = await self.session.execute(
                select(Project).where(Project.id.in_(p_ids))
            )
            projects = result.scalars().all()
            by_id = {p.id: p for p in projects}

            owner_ids = list(set(p.owner_id for p in projects))
            owners_map = {}
            if owner_ids:
                result = await self.session.execute(select(User).where(User.id.in_(owner_ids)))
                owners_map = {u.id: u for u in result.scalars().all()}

            for pid in p_ids:
                p = by_id.get(pid)
                if not p:
                    continue
                row = p_map[pid]
                owner = owners_map.get(p.owner_id)
                projects_data.append({
                    "id": p.id,
                    "type": "project",
                    "title": p.title,
                    "description": p.description,
                    "required_skills": p.required_skills,
                    "owner_name": owner.full_name if owner else None,
                    "match_score": float(row[6]),
                    "created_at": p.created_at.isoformat(),
                })

        # Competitions tetap pake MongoDB
        competition_data = []
        try:
            coll = get_competition_collection()
            cursor = coll.find({}).limit(20)
            lomba_data = await cursor.to_list(length=20)
            for item in lomba_data:
                item["_id"] = str(item["_id"])
                score = 0
                text_to_search = f"{item.get('judul', '')} {item.get('caption', '')}".lower()
                for us in user_skills_lower:
                    if us in text_to_search:
                        score += 1
                if score > 0 or not user_skills_lower:
                    c_item = dict(item)
                    c_item["type"] = "competition"
                    c_item["match_score"] = score
                    competition_data.append(c_item)
            competition_data.sort(key=lambda x: x.get("match_score", 0), reverse=True)
            competition_data = competition_data[:5]
        except Exception as e:
            logger.exception("Error fetching lomba")

        result_data = {
            "showcases": showcases_data,
            "projects": projects_data,
            "competitions": competition_data,
        }
        await cache.set(cache_key, result_data, ttl=60)
        return result_data
