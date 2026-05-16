import os
from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from motor.motor_asyncio import AsyncIOMotorClient
from app.core.security import verify_token
from app.core.database import get_db

router = APIRouter(prefix="/competitions", tags=["Lomba / Competitions"])

MONGO_URI = os.getenv("MONGO_URI")
client = AsyncIOMotorClient(MONGO_URI)
db_mongo = client["competition_scraper"]
collection = db_mongo["competition"]

@router.get("/all", summary="Lihat Semua Lomba")
async def get_all_competitions():
    """Ambil semua data lomba langsung dari MongoDB."""
    try:
        cursor = collection.find({})
        data = await cursor.to_list(length=None)
        for item in data:
            item["_id"] = str(item["_id"])
        return {"status": "success", "total": len(data), "data": data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal memuat data lomba: {str(e)}")

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
        cursor = collection.find({})
        data = await cursor.to_list(length=None)
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
                
        # Tampilkan yang score > 0, atau tampilkan semua jika user belum mengisi skill
        if score > 0 or len(user_skills) == 0:
            item_copy = dict(item)
            item_copy['match_score'] = score
            relevant_data.append(item_copy)
            
    # Sort by match score
    relevant_data.sort(key=lambda x: x.get('match_score', 0), reverse=True)
    
    return {"status": "success", "total": len(relevant_data), "data": relevant_data}
