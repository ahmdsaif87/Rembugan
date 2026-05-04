from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from zoneinfo import ZoneInfo
from app.core.database import get_db
from app.core.security import verify_token

router = APIRouter(prefix="/profile", tags=["Profil User"])

@router.get("/me", summary="Lihat Profil Saya Sendiri")
async def get_my_profile(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    return await get_profile(uid, db)

@router.get("/{user_id}", summary="Lihat Profil Pengguna Lain")
async def get_profile(
    user_id: str,
    db: Prisma = Depends(get_db),
):
    user = await db.user.find_unique(
        where={"id": user_id},
        include={
            "skills": {"include": {"skill": True}},
            "experiences": True,
            "showcases": True,
            "ownedProjects": {"where": {"status": "completed"}}
        }
    )
    
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
        
    skills = [s.skill.name for s in user.skills] if user.skills else []
    
    return {
        "status": "success",
        "data": {
            "id": user.id,
            "full_name": user.full_name,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "social_links": user.social_links,
            "skills": skills,
            "experiences": [
                {
                    "id": exp.id,
                    "title": exp.title,
                    "company": exp.company,
                    "description": exp.description,
                    "start_date": exp.start_date.isoformat(),
                    "end_date": exp.end_date.isoformat() if exp.end_date else None
                } for exp in user.experiences
            ] if user.experiences else [],
            "project_history": [
                {
                    "id": p.id,
                    "title": p.title,
                } for p in user.ownedProjects
            ] if user.ownedProjects else [],
            "portfolios": sorted([
                {
                    "id": s.id,
                    "content": s.content,
                    "media_urls": s.media_urls,
                    "created_at": s.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat()
                } for s in user.showcases
            ], key=lambda x: x["created_at"], reverse=True) if user.showcases else [],
        }
    }
