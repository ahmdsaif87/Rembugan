from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import PJ_OPEN, FYP_MAX_ROWS
from app.core.logger import get_logger
from app.core.cache import cache
from app.services.embedding import cosine_similarity
from app.services.competitions import get_competition_collection

logger = get_logger(__name__)


class FypService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

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

        user_embedding = user.embedding
        user_skill_names = {s.skill.name.lower() for s in user.skills} if user.skills else set()
        user_skills_lower = list(user_skill_names)

        showcases = await self.db.showcase.find_many(
            take=50,
            order={"created_at": "desc"},
            include={"author": True, "project": True, "likes": True, "comments": True},
        )
        scored_showcases = []
        for s in showcases:
            s_emb = s.embedding
            score = cosine_similarity(user_embedding, s_emb) if user_embedding and s_emb else 0
            scored_showcases.append((score, s))
        scored_showcases.sort(key=lambda x: x[0], reverse=True)

        showcase_data = []
        for score, s in scored_showcases[:10]:
            showcase_data.append({
                "id": s.id,
                "type": "showcase",
                "content": s.content,
                "media_urls": s.media_urls,
                "tags": s.tags,
                "author_name": s.author.full_name if s.author else None,
                "author_photo": s.author.photo_url if s.author else None,
                "likes_count": len(s.likes) if s.likes else 0,
                "comments_count": len(s.comments) if s.comments else 0,
                "match_score": int(score * 100),
                "created_at": s.created_at.isoformat(),
            })

        projects = await self.db.project.find_many(
            where={"status": PJ_OPEN, "owner_id": {"not": user_id}},
            include={"owner": True},
            take=FYP_MAX_ROWS,
        )
        scored_projects = []
        for p in projects:
            p_emb = p.embedding
            score = cosine_similarity(user_embedding, p_emb) if user_embedding and p_emb else 0
            scored_projects.append({
                "id": p.id,
                "type": "project",
                "title": p.title,
                "description": p.description,
                "required_skills": p.required_skills,
                "owner_name": p.owner.full_name if p.owner else None,
                "match_score": score,
                "created_at": p.created_at.isoformat(),
            })
        scored_projects.sort(key=lambda x: x["match_score"], reverse=True)
        project_data = scored_projects[:10]

        competition_data = []
        try:
            coll = get_competition_collection()
            cursor = coll.find({}).limit(50)
            lomba_data = await cursor.to_list(length=50)
            for item in lomba_data:
                item["_id"] = str(item["_id"])
                score = 0
                text_to_search = f"{item.get('judul', '')} {item.get('caption', '')}".lower()
                for us in user_skills_lower:
                    if us in text_to_search:
                        score += 1
                if score > 0 or len(user_skills_lower) == 0:
                    c_item = dict(item)
                    c_item["type"] = "competition"
                    c_item["match_score"] = score
                    competition_data.append(c_item)
            competition_data.sort(key=lambda x: x.get("match_score", 0), reverse=True)
            competition_data = competition_data[:5]
        except Exception as e:
            logger.exception("Error fetching lomba")

        result = {
            "showcases": showcase_data,
            "projects": project_data,
            "competitions": competition_data,
        }
        await cache.set(cache_key, result, ttl=60)
        return result
