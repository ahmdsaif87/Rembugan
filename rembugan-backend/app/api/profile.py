from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma, Json
from app.core.dates import tz_iso
from pydantic import BaseModel, Field
from app.core.database import get_db
from app.core.security import verify_token, verify_token_optional
from app.core.constants import PJ_OPEN, ROLE_KETUA, ROLE_ADMIN
from app.services.embedding import cosine_similarity, reembed_user


router = APIRouter(prefix="/profile", tags=["Profil User"])


class SettingsUpdateInput(BaseModel):
    """Data untuk update settings profil."""
    handle: Optional[str] = Field(None, description="@username")
    bio: Optional[str] = Field(None, description="Bio singkat")
    interest: Optional[str] = Field(None, description="Minat/bidang")
    photo_url: Optional[str] = Field(None, description="URL foto profil")
    cover_url: Optional[str] = Field(None, description="URL cover profile")
    social_links: Optional[dict] = Field(None, description="Link sosial media (instagram, linkedin, website)")


@router.patch("/settings", summary="Update Settings Profil")
async def update_settings(
    data: SettingsUpdateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Update profil user (settings page)."""
    uid = user_token.get("uid")

    update_data = {}
    if data.handle is not None:
        existing = await db.user.find_first(where={"handle": data.handle, "id": {"not": uid}})
        if existing:
            raise HTTPException(status_code=400, detail="Username sudah digunakan")
        update_data["handle"] = data.handle
    if data.bio is not None:
        update_data["bio"] = data.bio
    if data.interest is not None:
        update_data["interest"] = data.interest
    if data.photo_url is not None:
        update_data["photo_url"] = data.photo_url
    if data.cover_url is not None:
        update_data["cover_url"] = data.cover_url
    if data.social_links is not None:
        update_data["social_links"] = Json(data.social_links)

    if not update_data:
        raise HTTPException(status_code=400, detail="Tidak ada data yang diupdate")

    user = await db.user.update(
        where={"id": uid},
        data=update_data,
    )

    await reembed_user(db, uid)

    return {
        "status": "success",
        "message": "Settings berhasil diupdate!",
        "data": {
            "handle": user.handle,
            "bio": user.bio,
            "interest": user.interest,
            "photo_url": user.photo_url,
            "cover_url": user.cover_url,
            "social_links": user.social_links,
        },
    }

@router.get("/recommended", summary="Rekomendasi User untuk Dikenal")
async def get_recommended_users(
    limit: int = Query(10, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil daftar user yang direkomendasikan untuk dikenal (exclude diri sendiri)."""
    uid = user_token.get("uid")

    current_user = await db.user.find_unique(
        where={"id": uid},
        include={
            "skills": {"include": {"skill": True}},
            "ownedProjects": True,
        },
    )
    if not current_user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")

    user_embedding = current_user.embedding

    # Cek apakah user punya open project (sebagai ketua)
    open_projects = [p for p in (current_user.ownedProjects or []) if p.status == PJ_OPEN]
    has_open_offerings = len(open_projects) > 0

    project_required_skills: set[str] = set()
    if has_open_offerings:
        for p in open_projects:
            project_required_skills.update(p.required_skills or [])

    matched_skills_len = len(user_embedding) if user_embedding else 0
    match_type = "project" if has_open_offerings and project_required_skills else "interest"

    others = await db.user.find_many(
        where={"id": {"not": uid}},
        take=100,
    )

    scored = []
    for u in others:
        u_emb = u.embedding
        score = 0
        if user_embedding and u_emb:
            score = int(cosine_similarity(user_embedding, u_emb) * 100)
        scored.append((score, u))

    scored.sort(key=lambda x: x[0], reverse=True)
    scored = scored[:limit]

    result = []
    for score, u in scored:
        result.append({
            "id": u.id,
            "full_name": u.full_name,
            "handle": u.handle,
            "nim": u.nim,
            "major": u.major,
            "bio": u.bio,
            "photo_url": u.photo_url,
            "skills": [s.skill.name for s in u.skills] if u.skills else [],
        })

    return {"status": "success", "data": result}


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
    return await get_profile_func(uid, db, user_token)

async def get_profile_func(
    user_id: str,
    db: Prisma,
    user_token: dict | None = None,
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
                "role": ROLE_KETUA,
                "created_at": tz_iso(p.created_at),
            })
    if user.memberships:
        for m in user.memberships:
            all_projects.append({
                "id": m.project.id,
                "title": m.project.title,
                "status": m.project.status,
                "role": m.role,
                "created_at": tz_iso(m.project.created_at),
            })
    all_projects.sort(key=lambda x: x["created_at"], reverse=True)
    
    connection_count = await db.connection.count(
        where={
            "OR": [
                {"sender_id": user.id, "status": "accepted"},
                {"receiver_id": user.id, "status": "accepted"},
            ]
        },
    )
    
    is_own_profile = user_token and user_token.get("uid") == user.id

    connection_status = None
    connection_id = None
    is_incoming = None
    if not is_own_profile and user_token:
        viewer_id = user_token.get("uid")
        existing_conn = await db.connection.find_first(
            where={
                "OR": [
                    {"sender_id": viewer_id, "receiver_id": user.id},
                    {"sender_id": user.id, "receiver_id": viewer_id},
                ]
            }
        )
        if existing_conn:
            connection_status = existing_conn.status
            connection_id = existing_conn.id
            is_incoming = existing_conn.receiver_id == viewer_id
    
    data = {
        "connection_status": connection_status,
        "connection_id": connection_id,
        "is_incoming": is_incoming,
        "connection_count": connection_count,
        "project_count": len(all_projects),
        "id": user.id,
        "full_name": user.full_name,
        "handle": user.handle,
        "interest": user.interest,
        "nim": user.nim,
        "faculty": user.faculty,

        "major": user.major,
        "bio": user.bio,
        "photo_url": user.photo_url,
        "cover_url": user.cover_url,
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
                "created_at": tz_iso(s.created_at)
            } for s in user.showcases
        ], key=lambda x: x["created_at"], reverse=True) if user.showcases else [],
    }
    
    # Email hanya untuk pemilik profil atau admin
    if is_own_profile or (user_token and user_token.get("role") == ROLE_ADMIN):
        data["email"] = user.email
        data["email_verified"] = user.email_verified

    return {"status": "success", "data": data}


@router.get("/{user_id}", summary="Lihat Profil Pengguna Lain")
async def get_profile_route(
    user_id: str,
    db: Prisma = Depends(get_db),
    user_token: dict | None = Depends(verify_token_optional),
):
    return await get_profile_func(user_id, db, user_token)
