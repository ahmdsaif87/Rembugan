from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.security import verify_token
from app.core.database import get_db
from app.services.competitions import get_competition_collection

router = APIRouter(prefix="/competitions", tags=["Lomba / Competitions"])

collection = get_competition_collection()

@router.get("/all", summary="Lihat Semua Lomba")
async def get_all_competitions():
    """Ambil semua data lomba langsung dari MongoDB."""
    try:
        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)
        for item in data:
            item["_id"] = str(item["_id"])
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
    """Ambil lomba yang disesuaikan dengan skill user (keyword matching sederhana di judul & caption)."""
    uid = user_token.get("uid")
    
    # Ambil skill user
    user = await db.user.find_unique(
        where={"id": uid},
        include={"skills": {"include": {"skill": True}}},
    )
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
        
    user_skills = [s.skill.name.lower() for s in user.skills] if user.skills else []
    
    try:
        cursor = collection.find({}).limit(50)
        data = await cursor.to_list(length=50)
        for item in data:
            item["_id"] = str(item["_id"])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")
        
    relevant_data = []
    
    for item in data:
        score = 0
        text_to_search = f"{item.get('judul', '')} {item.get('caption', '')}".lower()
        for us in user_skills:
            if us in text_to_search:
                score += 1
                
        if score > 0 or len(user_skills) == 0:
            item_copy = dict(item)
            item_copy['match_score'] = score
            relevant_data.append(item_copy)
            
    relevant_data.sort(key=lambda x: x.get('match_score', 0), reverse=True)
    
    return {"status": "success", "total": len(relevant_data), "data": relevant_data}
