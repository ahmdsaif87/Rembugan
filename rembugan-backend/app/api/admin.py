from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.security import verify_token
from typing import List, Dict, Any
import httpx

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

    # Get competitions count from external API
    try:
        import httpx
        LOMBA_URL = "https://raw.githubusercontent.com/ahmdsaif87/competition_scraper/main/api_collabfinder.json"

        async with httpx.AsyncClient() as client:
            response = await client.get(LOMBA_URL)
            response.raise_for_status()
            data = response.json()
            scraped_competitions = len(data)
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
    Get recent competitions from external API
    """
    try:
        import httpx
        LOMBA_URL = "https://raw.githubusercontent.com/ahmdsaif87/competition_scraper/main/api_collabfinder.json"

        async with httpx.AsyncClient() as client:
            response = await client.get(LOMBA_URL)
            response.raise_for_status()
            data = response.json()

            # Take only recent ones (limit)
            recent_data = data[:limit] if len(data) > limit else data

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