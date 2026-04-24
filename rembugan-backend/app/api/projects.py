from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma
from zoneinfo import ZoneInfo

from app.core.security import verify_token
from app.core.database import get_db
from app.schemas.project import ProjectCreateInput
from app.services.matchmaking import calculate_match_score

router = APIRouter(prefix="/projects", tags=["2. Proyek & Kolaborasi"])


@router.post("/create", summary="Buat Proyek Baru")
async def create_project(
    data: ProjectCreateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Buat proyek/lowongan baru. 
    User yang sedang login otomatis menjadi 'owner' proyek.
    """
    uid = user_token.get("uid")

    user = await db.user.find_unique(where={"id": uid})
    if not user:
        raise HTTPException(status_code=404, detail="User belum terdaftar. Harap selesaikan onboarding.")

    project = await db.project.create(
        data={
            "owner_id": uid,
            "title": data.title,
            "description": data.description,
            "required_skills": data.required_skills,
            "members": {
                "create": {
                    "user_id": uid,
                    "role": "Ketua",
                }
            },
        },
        include={"owner": True, "members": True},
    )

    return {
        "status": "success",
        "message": f"Proyek '{project.title}' berhasil dibuat!",
        "data": {
            "id": project.id,
            "title": project.title,
            "description": project.description,
            "required_skills": project.required_skills,
            "status": project.status,
            "owner": project.owner.full_name if project.owner else None,
            "created_at": project.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        },
    }


@router.get("/explore", summary="Lihat Semua Proyek yang Terbuka (Match Score)")
async def get_all_projects(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Ambil daftar semua proyek dengan status 'open', lengkap dengan info owner.
    Daftar diurutkan berdasarkan 'Match Score' (kecocokan skill user dengan kebutuhan proyek).
    """
    uid = user_token.get("uid")
    
    # Ambil data user yang sedang login beserta skills-nya
    user = await db.user.find_unique(
        where={"id": uid},
        include={"skills": {"include": {"skill": True}}},
    )
    
    if not user:
        raise HTTPException(status_code=404, detail="User belum terdaftar.")

    user_skills = [us.skill.name for us in user.skills] if user.skills else []

    # Ambil proyek-proyek yang open dan bukan milik user sendiri
    projects = await db.project.find_many(
        where={"status": "open", "owner_id": {"not": uid}},
        include={
            "owner": True,
            "members": True,
        },
        order={"created_at": "desc"},
    )

    scored_projects = []
    for p in projects:
        score = calculate_match_score(user_skills, p.required_skills)
        scored_projects.append({
            "id": p.id,
            "title": p.title,
            "description": p.description,
            "required_skills": p.required_skills,
            "status": p.status,
            "owner_name": p.owner.full_name if p.owner else None,
            "member_count": len(p.members) if p.members else 0,
            "match_score": score,
            "created_at": p.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        })
        
    # Urutkan berdasarkan match score (tertinggi di atas)
    scored_projects.sort(key=lambda x: x["match_score"], reverse=True)
    
    # Pagination skip & take manual di list memory karena order by score tidak bisa langsung di DB Prisma
    start = (page - 1) * limit
    paginated_projects = scored_projects[start:start + limit]

    return {
        "status": "success", 
        "page": page,
        "limit": limit,
        "total_projects_available": len(scored_projects),
        "data": paginated_projects
    }


@router.get("/my-projects", summary="Lihat Proyek Milik Saya")
async def get_my_projects(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil semua proyek yang dimiliki oleh user yang sedang login."""
    user_id = user_token.get("uid")

    projects = await db.project.find_many(
        where={"owner_id": user_id},
        include={"members": True},
        order={"created_at": "desc"},
    )

    result = []
    for p in projects:
        result.append({
            "id": p.id,
            "title": p.title,
            "description": p.description,
            "required_skills": p.required_skills,
            "status": p.status,
            "member_count": len(p.members) if p.members else 0,
            "created_at": p.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        })

    return {"status": "success", "data": result}


@router.get("/{project_id}", summary="Detail Satu Proyek")
async def get_project_detail(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil detail lengkap satu proyek beserta semua member dan task-nya."""
    project = await db.project.find_unique(
        where={"id": project_id},
        include={
            "owner": True,
            "members": {"include": {"user": True}},
            "tasks": {"include": {"assignee": True}},
            "applications": {"include": {"applicant": True}},
        },
    )

    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    members = []
    if project.members:
        for m in project.members:
            members.append({
                "id": m.id,
                "user_id": m.user_id,
                "name": m.user.full_name if m.user else None,
                "role": m.role,
            })

    tasks = []
    if project.tasks:
        for t in project.tasks:
            tasks.append({
                "id": t.id,
                "title": t.title,
                "status": t.status,
                "assignee_name": t.assignee.full_name if t.assignee else None,
            })

    return {
        "status": "success",
        "data": {
            "id": project.id,
            "title": project.title,
            "description": project.description,
            "required_skills": project.required_skills,
            "status": project.status,
            "owner_name": project.owner.full_name if project.owner else None,
            "members": members,
            "tasks": tasks,
            "created_at": project.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        },
    }