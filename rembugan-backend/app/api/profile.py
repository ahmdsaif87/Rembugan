from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma
from zoneinfo import ZoneInfo
from typing import List
from app.core.database import get_db
from app.core.security import verify_token

router = APIRouter(prefix="/profile", tags=["Profil User"])

@router.get("/search", summary="Cari User Berdasarkan Nama atau NIM")
async def search_users(
    q: str = Query(..., min_length=1, description="Kata kunci pencarian (nama atau NIM)"),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    users = await db.user.find_many(
        where={
            "OR": [
                {"full_name": {"contains": q, "mode": "insensitive"}},
                {"nim": {"contains": q}},
            ]
        },
        take=20,
        order={"full_name": "asc"},
    )
    
    result = []
    for u in users:
        result.append({
            "id": u.id,
            "full_name": u.full_name,
            "nim": u.nim,
            "bio": u.bio,
            "photo_url": u.photo_url,
            "major": u.major,
        })
    
    return {"status": "success", "total": len(result), "data": result}

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
            "showcases": {
                "include": {
                    "likes": True,
                    "comments": True,
                }
            },
            "ownedProjects": True,
            "memberships": {"include": {"project": True}},
        }
    )
    
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
        
    skills = [s.skill.name for s in user.skills] if user.skills else []
    
    all_projects = []
    if user.ownedProjects:
        for p in user.ownedProjects:
            all_projects.append({
                "id": p.id,
                "title": p.title,
                "status": p.status,
                "role": "Ketua",
                "created_at": p.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            })
    if user.memberships:
        for m in user.memberships:
            all_projects.append({
                "id": m.project.id,
                "title": m.project.title,
                "status": m.project.status,
                "role": m.role,
                "created_at": m.project.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            })
    all_projects.sort(key=lambda x: x["created_at"], reverse=True)
    
    return {
        "status": "success",
        "data": {
            "id": user.id,
            "full_name": user.full_name,
            "nim": user.nim,
            "major": user.major,
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
            "project_history": all_projects,
            "portfolios": sorted([
                {
                    "id": s.id,
                    "content": s.content,
                    "media_urls": s.media_urls,
                    "tags": s.tags,
                    "likes_count": len(s.likes) if s.likes else 0,
                    "comments_count": len(s.comments) if s.comments else 0,
                    "created_at": s.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat()
                } for s in user.showcases
            ], key=lambda x: x["created_at"], reverse=True) if user.showcases else [],
        }
    }
