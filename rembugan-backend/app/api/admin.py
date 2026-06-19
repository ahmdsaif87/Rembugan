from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.security import verify_admin_token, hash_password
from app.schemas.auth import AdminCreateUserInput, AdminResetPasswordInput
from app.core.constants import PJ_COMPLETED, APP_PENDING
from app.services.competitions import get_competition_collection

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])


@router.post("/users/reset-password", summary="[Admin] Reset Password User")
async def admin_reset_user_password(
    data: AdminResetPasswordInput,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    user = await db.user.find_unique(where={"email": data.email})
    if not user:
        raise HTTPException(status_code=404, detail="User dengan email tersebut tidak ditemukan.")

    new_hashed = hash_password(data.new_password)
    await db.user.update(
        where={"id": user.id},
        data={"password": new_hashed},
    )

    return {
        "status": "success",
        "message": f"Password user {user.full_name} (email: {data.email}) berhasil direset.",
    }


@router.post("/users", summary="[Admin] Register User Baru")
async def admin_create_user(
    data: AdminCreateUserInput,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    existing = await db.user.find_unique(where={"email": data.email})
    if existing:
        raise HTTPException(status_code=400, detail="Email sudah terdaftar.")

    hashed = hash_password(data.password)
    user = await db.user.create(
        data={
            "email": data.email,
            "password": hashed,
            "full_name": data.full_name,
            "interest": data.interest,
        }
    )

    return {
        "status": "success",
        "message": f"User {user.full_name} berhasil dibuat.",
        "data": {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name,
            "interest": user.interest,
            "is_onboarded": user.is_onboarded,
        },
    }


@router.get("/stats", summary="Get Dashboard Statistics")
async def get_dashboard_stats(
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    total_users = await db.user.count()
    active_projects = await db.project.count(where={"status": {"not": PJ_COMPLETED}})
    total_projects = await db.project.count()
    total_showcases = await db.showcase.count()
    pending_applications = await db.projectapplication.count(where={"status": APP_PENDING})
    total_tasks = await db.task.count()
    scraped_competitions = await _count_competitions()

    return {
        "status": "success",
        "data": {
            "total_users": total_users,
            "active_projects": active_projects,
            "total_projects": total_projects,
            "total_showcases": total_showcases,
            "pending_applications": pending_applications,
            "total_tasks": total_tasks,
            "scraped_competitions": scraped_competitions,
        }
    }

@router.get("/users", summary="Get All Users for Admin")
async def get_all_users(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    users = await db.user.find_many(
        skip=skip,
        take=limit,
        include={
            "skills": {"include": {"skill": True}},
            "experiences": True,
            "showcases": True,
            "ownedProjects": True,
            "memberships": True,
        },
        order={"created_at": "desc"}
    )

    total = await db.user.count()

    return {
        "status": "success",
        "data": users,
        "pagination": {
            "skip": skip,
            "limit": limit,
            "total": total,
        }
    }

@router.get("/projects", summary="Get All Projects for Admin")
async def get_all_projects(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    projects = await db.project.find_many(
        skip=skip,
        take=limit,
        include={
            "owner": True,
            "members": {"include": {"user": True}},
            "applications": {"include": {"applicant": True}},
            "tasks": True,
        },
        order={"created_at": "desc"}
    )

    total = await db.project.count()

    return {
        "status": "success",
        "data": projects,
        "pagination": {
            "skip": skip,
            "limit": limit,
            "total": total,
        }
    }

@router.get("/showcases", summary="Get All Showcases for Admin")
async def get_all_showcases(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    showcases = await db.showcase.find_many(
        skip=skip,
        take=limit,
        include={
            "author": True,
            "project": True,
            "likes": {"include": {"user": True}},
            "comments": {
                "include": {
                    "user": True,
                    "replies": {"include": {"user": True}}
                }
            },
        },
        order={"created_at": "desc"}
    )

    total = await db.showcase.count()

    return {
        "status": "success",
        "data": showcases,
        "pagination": {
            "skip": skip,
            "limit": limit,
            "total": total,
        }
    }

@router.get("/tasks", summary="Get All Tasks for Admin")
async def get_all_tasks(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    tasks = await db.task.find_many(
        skip=skip,
        take=limit,
        include={
            "project": True,
            "assignee": True,
        },
        order={"created_at": "desc"}
    )

    total = await db.task.count()

    return {
        "status": "success",
        "data": tasks,
        "pagination": {
            "skip": skip,
            "limit": limit,
            "total": total,
        }
    }

@router.get("/applications", summary="Get All Applications for Admin")
async def get_all_applications(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    applications = await db.projectapplication.find_many(
        skip=skip,
        take=limit,
        include={
            "project": True,
            "applicant": True,
        },
        order={"applied_at": "desc"}
    )

    total = await db.projectapplication.count()

    return {
        "status": "success",
        "data": applications,
        "pagination": {
            "skip": skip,
            "limit": limit,
            "total": total,
        }
    }

@router.get("/competitions", summary="Get Recent Competitions for Admin")
async def get_recent_competitions(
    admin_token: dict = Depends(verify_admin_token),
    limit: int = 20,
):
    try:
        coll = get_competition_collection()
        cursor = coll.find({}).limit(limit)
        recent_data = await cursor.to_list(length=None)
        for item in recent_data:
            item["_id"] = str(item["_id"])

        return {
            "status": "success",
            "data": recent_data,
            "total": len(recent_data)
        }
    except Exception as e:
        return {
            "status": "error",
            "data": [],
            "message": f"Failed to fetch competitions: {str(e)}"
        }

@router.delete("/users/{user_id}", summary="Delete User for Admin")
async def delete_user(
    user_id: str,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    try:
        await db.user.delete(where={"id": user_id})
        return {"status": "success", "message": "User deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/projects/{project_id}", summary="Delete Project for Admin")
async def delete_project(
    project_id: str,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    try:
        await db.project.delete(where={"id": project_id})
        return {"status": "success", "message": "Project deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/showcases/{showcase_id}", summary="Delete Showcase for Admin")
async def delete_showcase(
    showcase_id: str,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    try:
        await db.showcase.delete(where={"id": showcase_id})
        return {"status": "success", "message": "Showcase deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/tasks/{task_id}", summary="Delete Task for Admin")
async def delete_task(
    task_id: str,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    try:
        await db.task.delete(where={"id": task_id})
        return {"status": "success", "message": "Task deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/applications/{application_id}", summary="Delete Application for Admin")
async def delete_application(
    application_id: str,
    admin_token: dict = Depends(verify_admin_token),
    db: Prisma = Depends(get_db),
):
    try:
        await db.projectapplication.delete(where={"id": application_id})
        return {"status": "success", "message": "Application deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/competitions/{competition_id}", summary="Delete Competition for Admin")
async def delete_competition(
    competition_id: str,
    admin_token: dict = Depends(verify_admin_token),
):
    deleted = await _delete_competition(competition_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Competition not found")
    return {"status": "success", "message": "Competition deleted successfully"}


async def _count_competitions() -> int:
    try:
        coll = get_competition_collection()
        return await coll.count_documents({})
    except Exception:
        return 0


async def _delete_competition(competition_id: str) -> bool:
    try:
        from bson.objectid import ObjectId
        coll = get_competition_collection()
        result = await coll.delete_one({"_id": ObjectId(competition_id)})
        return result.deleted_count > 0
    except Exception:
        return False
