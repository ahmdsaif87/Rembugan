from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.security import verify_token
from typing import List, Dict, Any

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])

@router.get("/stats", summary="Get Dashboard Statistics")
async def get_dashboard_stats(
    db: Prisma = Depends(get_db),
):
    """
    Get statistics for admin dashboard
    """
    # Get total users
    total_users = await db.user.count()

    # Get active projects (status != 'completed')
    active_projects = await db.project.count(where={"status": {"not": "completed"}})

    # Get total projects
    total_projects = await db.project.count()

    # Get total showcases
    total_showcases = await db.showcase.count()

    # Get pending applications
    pending_applications = await db.projectapplication.count(where={"status": "pending"})

    # Get total tasks
    total_tasks = await db.task.count()

    # Get competitions count from MongoDB
    try:
        from app.api.competitions import collection as competition_collection
        scraped_competitions = await competition_collection.count_documents({})
    except:
        scraped_competitions = 0

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
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    """
    Get all users with pagination
    """
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
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    """
    Get all projects with pagination
    """
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
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    """
    Get all showcases with pagination
    """
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
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    """
    Get all tasks with pagination
    """
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
    skip: int = 0,
    limit: int = 50,
    db: Prisma = Depends(get_db),
):
    """
    Get all applications with pagination
    """
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
    limit: int = 20,
):
    """
    Get recent competitions from MongoDB
    """
    try:
        from app.api.competitions import collection as competition_collection
        cursor = competition_collection.find({}).limit(limit)
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
    db: Prisma = Depends(get_db),
):
    """
    Delete a user
    """
    try:
        await db.user.delete(where={"id": user_id})
        return {"status": "success", "message": "User deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/projects/{project_id}", summary="Delete Project for Admin")
async def delete_project(
    project_id: str,
    db: Prisma = Depends(get_db),
):
    """
    Delete a project
    """
    try:
        await db.project.delete(where={"id": project_id})
        return {"status": "success", "message": "Project deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/showcases/{showcase_id}", summary="Delete Showcase for Admin")
async def delete_showcase(
    showcase_id: str,
    db: Prisma = Depends(get_db),
):
    """
    Delete a showcase
    """
    try:
        await db.showcase.delete(where={"id": showcase_id})
        return {"status": "success", "message": "Showcase deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/tasks/{task_id}", summary="Delete Task for Admin")
async def delete_task(
    task_id: str,
    db: Prisma = Depends(get_db),
):
    """
    Delete a task
    """
    try:
        await db.task.delete(where={"id": task_id})
        return {"status": "success", "message": "Task deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/applications/{application_id}", summary="Delete Application for Admin")
async def delete_application(
    application_id: str,
    db: Prisma = Depends(get_db),
):
    """
    Delete a project application
    """
    try:
        await db.projectapplication.delete(where={"id": application_id})
        return {"status": "success", "message": "Application deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.delete("/competitions/{competition_id}", summary="Delete Competition for Admin")
async def delete_competition(
    competition_id: str,
):
    """
    Delete a competition from MongoDB
    """
    try:
        from app.api.competitions import collection as competition_collection
        from bson.objectid import ObjectId
        result = await competition_collection.delete_one({"_id": ObjectId(competition_id)})
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Competition not found")
        return {"status": "success", "message": "Competition deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))