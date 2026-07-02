import re
from datetime import datetime
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma, Json
from app.core.dates import tz_iso
from pydantic import BaseModel, Field
from app.core.database import get_db
from app.core.security import verify_token, verify_token_optional
from app.core.constants import PJ_OPEN, ROLE_KETUA, ROLE_ADMIN
from app.schemas.user import ExperienceInput
from app.services.embedding import cosine_similarity, reembed_user


router = APIRouter(prefix="/profile", tags=["Profil User"])


def _parse_duration(duration: str) -> tuple[datetime, datetime | None]:
    """Parse free-text duration menjadi start_date & end_date."""
    if not duration or not duration.strip():
        now = datetime.now()
        return now, None

    parts = re.split(r'\s*[-–—]+\s*', duration.strip())
    if len(parts) == 2:
        start_str, end_str = parts[0].strip(), parts[1].strip()
        start = _parse_date(start_str) or datetime.now()
        end = _parse_date(end_str) if end_str and end_str.lower() not in ('now', 'present', 'sekarang', 'saat ini') else None
        return start, end

    parsed = _parse_date(duration.strip())
    if parsed:
        return parsed, None

    return datetime.now(), None


def _parse_date(s: str) -> datetime | None:
    """Coba parse berbagai format tanggal umum."""
    s = s.strip()
    if not s:
        return None

    fmts = [
        "%Y-%m-%d", "%Y-%m", "%Y",
        "%d/%m/%Y", "%m/%Y",
        "%B %Y", "%b %Y",
    ]
    for fmt in fmts:
        try:
            dt = datetime.strptime(s, fmt)
            if fmt == "%Y":
                return datetime(dt.year, 1, 1)
            if fmt == "%Y-%m":
                return datetime(dt.year, dt.month, 1)
            if fmt == "%m/%Y":
                return datetime(dt.year, dt.month, 1)
            return dt
        except ValueError:
            continue

    month_map = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        'januari': 1, 'februari': 2, 'maret': 3, 'april': 4, 'mei': 5, 'juni': 6,
        'juli': 7, 'agustus': 8, 'september': 9, 'oktober': 10, 'november': 11, 'desember': 12,
    }
    m = re.match(r'(\d{4})', s)
    if m:
        return datetime(int(m.group(1)), 1, 1)

    for name, month_num in month_map.items():
        if name in s.lower():
            m = re.search(r'(\d{4})', s)
            if m:
                return datetime(int(m.group(1)), month_num, 1)

    return None


class SettingsUpdateInput(BaseModel):
    """Data untuk update settings profil."""
    full_name: Optional[str] = Field(None, description="Nama lengkap")
    handle: Optional[str] = Field(None, description="@username")
    bio: Optional[str] = Field(None, description="Bio singkat")
    interest: Optional[str] = Field(None, description="Minat/bidang")
    photo_url: Optional[str] = Field(None, description="URL foto profil")
    cover_url: Optional[str] = Field(None, description="URL cover profile")
    social_links: Optional[dict] = Field(None, description="Link sosial media (instagram, linkedin, website)")
    skills: Optional[List[str]] = Field(None, description="Daftar skill/keahlian")
    experiences: Optional[List[ExperienceInput]] = Field(None, description="Riwayat pengalaman")


@router.patch("/settings", summary="Update Settings Profil")
async def update_settings(
    data: SettingsUpdateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Update profil user (settings page)."""
    uid = user_token.get("uid")

    update_data = {}
    if data.full_name is not None:
        name = data.full_name.strip()
        if not name:
            raise HTTPException(status_code=400, detail="Nama wajib diisi")
        update_data["full_name"] = name
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

    if not update_data and data.skills is None and data.experiences is None:
        raise HTTPException(status_code=400, detail="Tidak ada data yang diupdate")

    if update_data:
        await db.user.update(
            where={"id": uid},
            data=update_data,
        )

    if data.skills is not None:
        skill_names = []
        seen = set()
        for raw_skill in data.skills:
            skill_name = raw_skill.strip()
            key = skill_name.lower()
            if skill_name and key not in seen:
                seen.add(key)
                skill_names.append(skill_name)

        await db.userskill.delete_many(where={"user_id": uid})
        for skill_name in skill_names:
            skill = await db.skill.find_unique(where={"name": skill_name})
            if skill is None:
                skill = await db.skill.create(data={"name": skill_name})
            await db.userskill.create(data={"user_id": uid, "skill_id": skill.id})

    if data.experiences is not None:
        await db.experience.delete_many(where={"user_id": uid})
        for exp in data.experiences:
            start_date, end_date = _parse_duration(exp.duration)
            await db.experience.create(data={
                "user_id": uid,
                "title": exp.title,
                "company": exp.organization,
                "description": exp.description,
                "start_date": start_date,
                "end_date": end_date,
            })

    await reembed_user(db, uid)

    user = await db.user.find_unique(
        where={"id": uid},
        include={"experiences": True},
    )

    return {
        "status": "success",
        "message": "Settings berhasil diupdate!",
        "data": {
            "handle": user.handle,
            "full_name": user.full_name,
            "bio": user.bio,
            "interest": user.interest,
            "photo_url": user.photo_url,
            "cover_url": user.cover_url,
            "social_links": user.social_links,
            "skills": skill_names if data.skills is not None else None,
            "experiences": [
                {
                    "id": exp.id,
                    "title": exp.title,
                    "company": exp.company,
                    "description": exp.description,
                    "start_date": exp.start_date.isoformat(),
                    "end_date": exp.end_date.isoformat() if exp.end_date else None,
                }
                for exp in user.experiences
            ] if user.experiences else [],
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
