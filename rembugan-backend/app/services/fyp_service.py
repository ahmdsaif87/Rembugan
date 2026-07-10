from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import PJ_OPEN
from app.core.logger import get_logger
from app.core.cache import cache
from app.services.competitions import get_competition_collection

logger = get_logger(__name__)


class FypService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def _get_user_embedding(self, user_id: str):
        import json
        row = await self.db.query_raw(
            'SELECT embedding::text FROM "User" WHERE id = $1', user_id
        )
        if row and row[0]["embedding"]:
            return json.loads(row[0]["embedding"])
        return None

    async def get_fyp(self, user_id: str) -> dict:
        cache_key = f"fyp:{user_id}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached

        user = await self.db.user.find_unique(
            where={"id": user_id},
            include={"skills": {"include": {"skill": True}}},
        )
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        user_embedding = await self._get_user_embedding(user_id)
        user_skill_names = {s.skill.name.lower() for s in user.skills} if user.skills else set()
        user_skills_lower = list(user_skill_names)

        # Showcases: pgvector scoring, fallback ke created_at desc kalo kosong
        showcases_data = []
        vec = f'[{",".join(str(x) for x in user_embedding)}]' if user_embedding else None
        if vec:
            rows = await self.db.query_raw(
                'SELECT id, content, media_urls, tags, author_id, created_at, '
                '1 - (embedding <=> $1::vector) AS match_score '
                'FROM "Showcase" WHERE author_id != $2 '
                'AND 1 - (embedding <=> $1::vector) > 0.15 '
                'ORDER BY embedding <=> $1::vector LIMIT 10',
                vec, user_id
            )
        if not vec or not rows:
            rows = await self.db.query_raw(
                'SELECT id, content, media_urls, tags, author_id, created_at, 0 AS match_score '
                'FROM "Showcase" WHERE author_id != $1 '
                'ORDER BY created_at DESC LIMIT 10',
                user_id
            )
        if rows:
            s_ids = [r["id"] for r in rows]
            s_map = {r["id"]: r for r in rows}
            showcases = await self.db.showcase.find_many(
                where={"id": {"in": s_ids}},
                include={"author": True, "project": True, "likes": True, "comments": True},
            )
            by_id = {s.id: s for s in showcases}
            for sid in s_ids:
                s = by_id.get(sid)
                if not s:
                    continue
                row = s_map[sid]
                showcases_data.append({
                    "id": s.id,
                    "type": "showcase",
                    "content": s.content,
                    "media_urls": s.media_urls,
                    "tags": s.tags,
                    "author_name": s.author.full_name if s.author else None,
                    "author_photo": s.author.photo_url if s.author else None,
                    "likes_count": len(s.likes) if s.likes else 0,
                    "comments_count": len(s.comments) if s.comments else 0,
                    "match_score": int(float(row["match_score"]) * 100),
                    "created_at": s.created_at.isoformat(),
                })

        # Projects: pgvector scoring, fallback ke created_at desc kalo kosong
        projects_data = []
        vec = f'[{",".join(str(x) for x in user_embedding)}]' if user_embedding else None
        if vec:
            rows = await self.db.query_raw(
                'SELECT id, title, description, required_skills, owner_id, created_at, '
                '1 - (embedding <=> $1::vector) AS match_score '
                'FROM "Project" WHERE status = $2 '
                'AND 1 - (embedding <=> $1::vector) > 0.15 '
                'ORDER BY embedding <=> $1::vector LIMIT 10',
                vec, PJ_OPEN
            )
        if not vec or not rows:
            rows = await self.db.query_raw(
                'SELECT id, title, description, required_skills, owner_id, created_at, 0 AS match_score '
                'FROM "Project" WHERE status = $1 '
                'ORDER BY created_at DESC LIMIT 10',
                PJ_OPEN
            )
        if rows:
                p_ids = [r["id"] for r in rows]
                p_map = {r["id"]: r for r in rows}
                projects = await self.db.project.find_many(
                    where={"id": {"in": p_ids}},
                    include={"owner": True},
                )
                by_id = {p.id: p for p in projects}
                for pid in p_ids:
                    p = by_id.get(pid)
                    if not p:
                        continue
                    row = p_map[pid]
                    projects_data.append({
                        "id": p.id,
                        "type": "project",
                        "title": p.title,
                        "description": p.description,
                        "required_skills": p.required_skills,
                        "owner_name": p.owner.full_name if p.owner else None,
                        "match_score": float(row["match_score"]),
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

        result = {
            "showcases": showcases_data,
            "projects": projects_data,
            "competitions": competition_data,
        }
        await cache.set(cache_key, result, ttl=60)
        return result
