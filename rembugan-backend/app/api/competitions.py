from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.security import verify_token
from app.core.database import get_db
from app.services.competitions import get_competition_collection
from app.services.embedding import generate, cosine_similarity

router = APIRouter(prefix="/competitions", tags=["Lomba / Competitions"])

collection = get_competition_collection()

<<<<<<< Updated upstream
@router.get("/all", summary="Lihat Semua Lomba")
async def get_all_competitions():
    """Ambil semua data lomba langsung dari MongoDB."""
=======
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


def _get_or_generate_embedding(item: dict) -> list[float]:
    cached = item.get("embedding")
    version = item.get("emb_v")
    if version == _EMB_VERSION and isinstance(cached, list) and len(cached) == 384:
        return [float(v) for v in cached]
    txt = _full_text(item)
    emb = generate(txt)
    item["embedding"] = emb
    item["emb_v"] = _EMB_VERSION
    return emb


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

>>>>>>> Stashed changes
    try:
        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)
        for item in data:
            item["_id"] = str(item["_id"])
<<<<<<< Updated upstream
=======
            poster = item.get("poster", "")
            local = _local_poster_url(poster)
            item["poster"] = f"{base}{local}" if local else ""

            comp_emb = _get_or_generate_embedding(item)
            score = 0
            if user_embedding and comp_emb:
                score = int(cosine_similarity(user_embedding, comp_emb) * 100)

            # Zero score if user has skills but no mention in text AND category doesn't match domain
            if user_skill_names:
                text = _full_text(item)
                skill_in_text = any(s in text for s in user_skill_names)
                kategori_val = (item.get("kategori") or "").lower().strip()
                domain_match = kategori_val in _TECH_KATEGORI
                if not skill_in_text and not domain_match:
                    score = 0

            item["match_score"] = score

        data.sort(key=lambda x: x.get("match_score", 0), reverse=True)

        # Cache embeddings back to MongoDB in background
        try:
            for item in data:
                if isinstance(item.get("embedding"), list):
                    await collection.update_one(
                        {"_id": item["_id"]},
                        {"$set": {"embedding": item["embedding"], "emb_v": _EMB_VERSION}},
                    )
        except Exception:
            pass

>>>>>>> Stashed changes
        return {"status": "success", "total": len(data), "data": data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")


@router.get("/stats", summary="Statistik Lomba")
async def get_competition_stats():
    """Ambil statistik lomba: by source, by deadline, by kategori."""
    try:
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
        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)
        for item in data:
            item["_id"] = str(item["_id"])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")

    relevant_data = []

    for item in data:
        comp_emb = _get_or_generate_embedding(item)
        score = 0
        if user_embedding and comp_emb:
            score = int(cosine_similarity(user_embedding, comp_emb) * 100)

        # Zero score if user has skills but no mention in text AND category doesn't match domain
        if user_skill_names:
            text = _full_text(item)
            skill_in_text = any(s in text for s in user_skill_names)
            kategori_val = (item.get("kategori") or "").lower().strip()
            domain_match = kategori_val in _TECH_KATEGORI
            if not skill_in_text and not domain_match:
                score = 0

        if score > 40:
            item_copy = dict(item)
            item_copy["match_score"] = score
            relevant_data.append(item_copy)

    relevant_data.sort(key=lambda x: x.get("match_score", 0), reverse=True)

    try:
        for item in data:
            if isinstance(item.get("embedding"), list):
                await collection.update_one(
                    {"_id": item["_id"]},
                    {"$set": {"embedding": item["embedding"], "emb_v": _EMB_VERSION}},
                )
    except Exception:
        pass

    return {"status": "success", "total": len(relevant_data), "data": relevant_data}
