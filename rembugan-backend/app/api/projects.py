from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma
from app.core.dates import tz_iso

from app.core.security import verify_token
from app.core.database import get_db
from app.core.constants import PJ_OPEN, PJ_COMPLETED, ROLE_KETUA, EXPLORE_MAX_ROWS
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

    create_data = {
        "owner_id": uid,
        "title": data.title,
        "description": data.description,
        "required_skills": data.required_skills,
        "members": {
            "create": {
                "user_id": uid,
                "role": ROLE_KETUA,
            }
        },
    }
    if data.faculty is not None:
        create_data["faculty"] = data.faculty
    if data.deadline is not None:
        create_data["deadline"] = data.deadline
    if data.total_slots is not None:
        create_data["total_slots"] = data.total_slots

    project = await db.project.create(
        data=create_data,
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
            "faculty": project.faculty,
            "deadline": tz_iso(project.deadline) if project.deadline else None,
            "total_slots": project.total_slots,
            "filled_slots": len(project.members) if project.members else 0,
            "owner": project.owner.full_name if project.owner else None,
            "created_at": tz_iso(project.created_at),
        },
    }


@router.get("/explore", summary="Lihat Semua Proyek yang Terbuka (Match Score)")
async def get_all_projects(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=50),
    faculty: str = Query(None, description="Filter by faculty"),
    min_slots: int = Query(None, ge=1, description="Min total slots"),
    max_slots: int = Query(None, ge=1, description="Max total slots"),
    deadline_before: str = Query(None, description="Filter deadline before (ISO datetime)"),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Ambil daftar semua proyek dengan status 'open', lengkap dengan info owner.
    Daftar diurutkan berdasarkan 'Match Score' (kecocokan skill user dengan kebutuhan proyek).

    Mendukung filter: faculty, min_slots, max_slots, deadline_before.
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

    # Build filter conditions
    where_conditions = {"status": PJ_OPEN, "owner_id": {"not": uid}}
    if faculty:
        where_conditions["faculty"] = faculty
    if min_slots is not None:
        where_conditions["total_slots"] = {"gte": min_slots}
    if max_slots is not None:
        if "total_slots" in where_conditions:
            where_conditions["total_slots"]["lte"] = max_slots
        else:
            where_conditions["total_slots"] = {"lte": max_slots}
    if deadline_before:
        try:
            dt = datetime.fromisoformat(deadline_before)
            where_conditions["deadline"] = {"lte": dt}
        except ValueError:
            pass

    # Hitung total dulu, baru ambil page dengan cap maksimal
    total_available = await db.project.count(where=where_conditions)
    max_fetch = min(total_available, EXPLORE_MAX_ROWS)  # safety cap
    
    projects = await db.project.find_many(
        where=where_conditions,
        include={
            "owner": True,
            "members": {
                "include": {"user": True}
            },
        },
        order={"created_at": "desc"},
        take=max_fetch,
    )

    scored_projects = []
    for p in projects:
        score = calculate_match_score(user_skills, p.required_skills)
        member_names = [m.user.full_name for m in p.members if m.user] if p.members else []
        member_avatars = [m.user.photo_url for m in p.members if m.user and m.user.photo_url] if p.members else []
        scored_projects.append({
            "id": p.id,
            "title": p.title,
            "description": p.description,
            "required_skills": p.required_skills,
            "status": p.status,
            "deadline": tz_iso(p.deadline) if p.deadline else None,
            "total_slots": p.total_slots,
            "filled_slots": len(p.members) if p.members else 0,
            "owner_name": p.owner.full_name if p.owner else None,
            "owner_photo": p.owner.photo_url if p.owner else None,
            "owner_id": str(p.owner.id) if p.owner else None,
            "member_names": member_names,
            "member_avatars": member_avatars,
            "member_count": len(p.members) if p.members else 0,
            "match_score": score,
            "created_at": tz_iso(p.created_at),
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
        "total_projects_available": total_available,
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
            "faculty": p.faculty,
            "deadline": tz_iso(p.deadline) if p.deadline else None,
            "total_slots": p.total_slots,
            "filled_slots": len(p.members) if p.members else 0,
            "member_count": len(p.members) if p.members else 0,
            "created_at": tz_iso(p.created_at),
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
            "faculty": project.faculty,
            "deadline": tz_iso(project.deadline) if project.deadline else None,
            "total_slots": project.total_slots,
            "filled_slots": len(project.members) if project.members else 0,
            "owner_name": project.owner.full_name if project.owner else None,
            "members": members,
            "tasks": tasks,
            "created_at": tz_iso(project.created_at),
        },
    }

@router.post("/{project_id}/archive", summary="Archive a project (set status to completed)")
async def archive_project(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Archive a project by setting its status to 'completed'. Only the owner can do this."""
    uid = user_token.get("uid")
    # Verify ownership
    project = await db.project.find_unique(
        where={"id": project_id},
        select={"owner_id": True, "status": True},
    )
    if not project:
        raise HTTPException(status_code=404, detail="Project not found.")
    if project.owner_id != uid:
        raise HTTPException(status_code=403, detail="Only the owner can archive the project.")
    # Update status
    updated = await db.project.update(
        where={"id": project_id},
        data={"status": PJ_COMPLETED},
        select={"id": True, "status": True},
    )
    return {"status": "success", "data": updated}