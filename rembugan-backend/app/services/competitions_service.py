import os
import hashlib
from fastapi import Depends, HTTPException
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.tasks import fire_and_forget
from app.core.cache import cache
from app.models import User
from app.services.competitions import get_competition_collection
from app.services.embedding import generate, cosine_similarity

POSTERS_DIR = os.path.join(os.path.dirname(__file__), "..", "static", "posters")


class CompetitionsService:
    EMB_VERSION = 3

    TECH_KATEGORI = {
        "it", "teknologi", "programming", "komputer", "informatika",
        "data", "ai", "digital", "software", "coding", "sains data",
        "machine learning", "cyber security", "jaringan",
    }

    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    @staticmethod
    def _full_text(item: dict) -> str:
        parts = [item.get("judul", ""), item.get("caption", ""), item.get("kategori", "")]
        return " ".join(p.lower() for p in parts if p)

    @staticmethod
    def _local_poster_url(poster_url: str) -> str:
        if not poster_url:
            return ""
        url_hash = hashlib.md5(poster_url.encode()).hexdigest()
        local_path = os.path.join(POSTERS_DIR, f"{url_hash}.jpg")
        if os.path.exists(local_path):
            return f"/static/posters/{url_hash}.jpg"
        return ""

    async def _cache_missing_embeddings(self, collection, items: list[dict]):
        try:
            for item in items:
                txt = self._full_text(item)
                emb = await generate(txt)
                if emb:
                    await collection.update_one(
                        {"_id": item["_id"]},
                        {"$set": {"embedding": emb, "emb_v": self.EMB_VERSION}},
                    )
        except Exception:
            pass

    async def get_all(self, user_id: str, base_url: str):
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()

        user_embedding = None
        if user:
            raw = await self.session.execute(
                text('SELECT embedding::text FROM "User" WHERE id = :uid'),
                {"uid": user_id},
            )
            emb_row = raw.fetchone()
            if emb_row and emb_row[0]:
                import json
                user_embedding = json.loads(emb_row[0])
        user_skill_names = {s.skill.name.lower() for s in (user.skills or [])} if user and user.skills else set()

        try:
            collection = get_competition_collection()
            if collection is None:
                return []

            cache_key = "competitions:all"
            cached = await cache.get(cache_key)
            if cached is not None:
                data = cached
            else:
                cursor = collection.find({}).limit(20)
                data = await cursor.to_list(length=20)
                for item in data:
                    item["_id"] = str(item["_id"])
                    poster = item.get("poster", "")
                    local = self._local_poster_url(poster)
                    item["poster"] = f"{base_url}{local}" if local else ""
                await cache.set(cache_key, data, ttl=300)

            items_needing_embed: list[dict] = []

            for item in data:
                kategori_val = (item.get("kategori") or "").lower().strip()
                domain_match = kategori_val in self.TECH_KATEGORI

                score = 0
                if user_embedding:
                    cached_emb = item.get("embedding")
                    version = item.get("emb_v")
                    if version == self.EMB_VERSION and isinstance(cached_emb, list) and len(cached_emb) == 384:
                        comp_emb = [float(v) for v in cached_emb]
                        score = int(cosine_similarity(user_embedding, comp_emb) * 100)
                    else:
                        items_needing_embed.append(item)

                if score == 0 and domain_match:
                    score = 30
                    if user_skill_names:
                        text_content = self._full_text(item)
                        if any(s in text_content for s in user_skill_names):
                            score = 60

                if user_skill_names and score > 0:
                    text_content = self._full_text(item)
                    skill_in_text = any(s in text_content for s in user_skill_names)
                    if not skill_in_text and not domain_match:
                        score = 0

                item["match_score"] = score

            if items_needing_embed:
                fire_and_forget(self._cache_missing_embeddings(collection, items_needing_embed), "cache_missing_embeddings")

            data.sort(key=lambda x: x.get("match_score", 0), reverse=True)

            return data
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")

    async def get_stats(self):
        try:
            collection = get_competition_collection()
            if collection is None:
                return {"by_source": [], "by_deadline": [], "by_kategori": []}

            cursor = collection.find({}).limit(20)
            data = await cursor.to_list(length=20)

            source_counts: dict[str, int] = {}
            deadline_counts: dict[str, int] = {}
            kategori_counts: dict[str, int] = {}

            for item in data:
                s = item.get("sumber", "Unknown")
                source_counts[s] = source_counts.get(s, 0) + 1

                ddl = item.get("deadline")
                if ddl:
                    deadline_counts[str(ddl)] = deadline_counts.get(str(ddl), 0) + 1

                kat = item.get("kategori")
                if kat:
                    kategori_counts[kat] = kategori_counts.get(kat, 0) + 1

            return {
                "by_source": [
                    {"name": k, "total": v}
                    for k, v in sorted(source_counts.items(), key=lambda x: x[1], reverse=True)
                ],
                "by_deadline": [
                    {"name": k, "total": v}
                    for k, v in sorted(deadline_counts.items(), key=lambda x: x[1], reverse=True)
                ],
                "by_kategori": [
                    {"name": k, "total": v}
                    for k, v in sorted(kategori_counts.items(), key=lambda x: x[1], reverse=True)
                ],
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Gagal memuat statistik: {str(e)}")

    async def get_relevant(self, user_id: str):
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        user_embedding = None
        raw = await self.session.execute(
            text('SELECT embedding::text FROM "User" WHERE id = :uid'),
            {"uid": user_id},
        )
        emb_row = raw.fetchone()
        if emb_row and emb_row[0]:
            import json
            user_embedding = json.loads(emb_row[0])
        user_skill_names = {s.skill.name.lower() for s in (user.skills or [])} if user.skills else set()

        try:
            collection = get_competition_collection()
            if collection is None:
                return []

            cursor = collection.find({}).limit(20)
            data = await cursor.to_list(length=20)
            for item in data:
                item["_id"] = str(item["_id"])
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")

        items_needing_embed: list[dict] = []
        relevant_data = []

        for item in data:
            kategori_val = (item.get("kategori") or "").lower().strip()
            domain_match = kategori_val in self.TECH_KATEGORI

            score = 0
            if user_embedding:
                cached_emb = item.get("embedding")
                version = item.get("emb_v")
                if version == self.EMB_VERSION and isinstance(cached_emb, list) and len(cached_emb) == 384:
                    comp_emb = [float(v) for v in cached_emb]
                    score = int(cosine_similarity(user_embedding, comp_emb) * 100)
                else:
                    items_needing_embed.append(item)

            if score == 0 and domain_match:
                score = 30
                if user_skill_names:
                    text_content = self._full_text(item)
                    if any(s in text_content for s in user_skill_names):
                        score = 60

            if user_skill_names and score > 0:
                text_content = self._full_text(item)
                skill_in_text = any(s in text_content for s in user_skill_names)
                if not skill_in_text and not domain_match:
                    score = 0

            if score > 40:
                item_copy = dict(item)
                item_copy["match_score"] = score
                relevant_data.append(item_copy)

        if items_needing_embed:
            fire_and_forget(self._cache_missing_embeddings(collection, items_needing_embed), "cache_missing_embeddings")

        relevant_data.sort(key=lambda x: x.get("match_score", 0), reverse=True)

        return relevant_data
