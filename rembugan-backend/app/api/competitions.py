import os
import hashlib
import asyncio
from fastapi import APIRouter, Depends, HTTPException, Request
from prisma import Prisma
from app.core.security import verify_token
from app.core.database import get_db
from app.services.competitions import get_competition_collection
from app.services.embedding import generate, cosine_similarity

router = APIRouter(prefix="/competitions", tags=["Lomba / Competitions"])

POSTERS_DIR = os.path.join(os.path.dirname(__file__), "..", "static", "posters")


def _local_poster_url(poster_url: str) -> str:
    if not poster_url:
        return ""
    url_hash = hashlib.md5(poster_url.encode()).hexdigest()
    local_path = os.path.join(POSTERS_DIR, f"{url_hash}.jpg")
    if os.path.exists(local_path):
        return f"/static/posters/{url_hash}.jpg"
    return ""


_EMB_VERSION = 3

# Broad categories that match tech-skilled users (skills like Python, JS, etc.)
_TECH_KATEGORI = {
    "it", "teknologi", "programming", "komputer", "informatika",
    "data", "ai", "digital", "software", "coding", "sains data",
    "machine learning", "cyber security", "jaringan",
}


def _full_text(item: dict) -> str:
    parts = [item.get("judul", ""), item.get("caption", ""), item.get("kategori", "")]
    return " ".join(p.lower() for p in parts if p)


async def _cache_missing_embeddings(collection, items: list[dict]):
    """Generate and cache embeddings for uncached competition items."""
    try:
        for item in items:
            txt = _full_text(item)
            emb = generate(txt)
            if emb:
                await collection.update_one(
                    {"_id": item["_id"]},
                    {"$set": {"embedding": emb, "emb_v": _EMB_VERSION}},
                )
    except Exception:
        pass


@router.get("/all", summary="Lihat Semua Lomba")
async def get_all_competitions(
    request: Request,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil semua data lomba — score 0 kalau gak ada skill match di judul/caption."""
    uid = user_token.get("uid")

    user = await db.user.find_unique(
        where={"id": uid},
        include={"skills": {"include": {"skill": True}}},
    )
    user_embedding = user.embedding if user else None
    user_skill_names = {s.skill.name.lower() for s in user.skills} if user and user.skills else set()


    try:
        collection = get_competition_collection()
        if collection is None:
            return {"status": "success", "total": 0, "data": []}

        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)
        base_url = str(request.base_url).rstrip("/")
        items_needing_embed: list[dict] = []

        for item in data:
            item["_id"] = str(item["_id"])
            poster = item.get("poster", "")
            local = _local_poster_url(poster)
            item["poster"] = f"{base_url}{local}" if local else ""

            kategori_val = (item.get("kategori") or "").lower().strip()
            domain_match = kategori_val in _TECH_KATEGORI

            score = 0
            if user_embedding:
                cached = item.get("embedding")
                version = item.get("emb_v")
                if version == _EMB_VERSION and isinstance(cached, list) and len(cached) == 384:
                    comp_emb = [float(v) for v in cached]
                    score = int(cosine_similarity(user_embedding, comp_emb) * 100)
                else:
                    items_needing_embed.append(item)

            # Fallback: use category-based score when no cached embedding
            if score == 0 and domain_match:
                score = 30
                if user_skill_names:
                    text = _full_text(item)
                    if any(s in text for s in user_skill_names):
                        score = 60

            # Zero score if user has skills but no mention in text AND category doesn't match domain
            if user_skill_names and score > 0:
                text = _full_text(item)
                skill_in_text = any(s in text for s in user_skill_names)
                if not skill_in_text and not domain_match:
                    score = 0

            item["match_score"] = score

        # Generate & cache embeddings for uncached items in background
        if items_needing_embed:
            asyncio.create_task(_cache_missing_embeddings(collection, items_needing_embed))

        data.sort(key=lambda x: x.get("match_score", 0), reverse=True)

        return {"status": "success", "total": len(data), "data": data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")


@router.get("/stats", summary="Statistik Lomba")
async def get_competition_stats():
    """Ambil statistik lomba: by source, by deadline, by kategori."""
    try:
        collection = get_competition_collection()
        if collection is None:
            return {"status": "success", "data": {"by_source": [], "by_deadline": [], "by_kategori": []}}

        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)

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
            "status": "success",
            "data": {
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
            },
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat statistik: {str(e)}")


@router.get("/relevant", summary="Lihat Lomba Relevan dengan Skill")
async def get_relevant_competitions(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil lomba relevan — score > 40 DAN ada keyword skill di judul/caption."""
    uid = user_token.get("uid")

    user = await db.user.find_unique(
        where={"id": uid},
        include={"skills": {"include": {"skill": True}}},
    )
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")

    user_embedding = user.embedding
    user_skill_names = {s.skill.name.lower() for s in user.skills} if user.skills else set()

    try:
        collection = get_competition_collection()
        if collection is None:
            return {"status": "success", "total": 0, "data": []}

        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)
        for item in data:
            item["_id"] = str(item["_id"])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")

    items_needing_embed: list[dict] = []
    relevant_data = []

    for item in data:
        kategori_val = (item.get("kategori") or "").lower().strip()
        domain_match = kategori_val in _TECH_KATEGORI

        score = 0
        if user_embedding:
            cached = item.get("embedding")
            version = item.get("emb_v")
            if version == _EMB_VERSION and isinstance(cached, list) and len(cached) == 384:
                comp_emb = [float(v) for v in cached]
                score = int(cosine_similarity(user_embedding, comp_emb) * 100)
            else:
                items_needing_embed.append(item)

        # Fallback: use category-based score when no cached embedding
        if score == 0 and domain_match:
            score = 30
            if user_skill_names:
                text = _full_text(item)
                if any(s in text for s in user_skill_names):
                    score = 60

        # Zero score if user has skills but no mention in text AND category doesn't match domain
        if user_skill_names and score > 0:
            text = _full_text(item)
            skill_in_text = any(s in text for s in user_skill_names)
            if not skill_in_text and not domain_match:
                score = 0

        if score > 40:
            item_copy = dict(item)
            item_copy["match_score"] = score
            relevant_data.append(item_copy)

    if items_needing_embed:
        asyncio.create_task(_cache_missing_embeddings(collection, items_needing_embed))

    relevant_data.sort(key=lambda x: x.get("match_score", 0), reverse=True)

    return {"status": "success", "total": len(relevant_data), "data": relevant_data}
