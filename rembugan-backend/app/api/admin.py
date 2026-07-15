from fastapi import APIRouter, Depends, Query
from app.core.response import response_success
from app.core.security import verify_admin_token
from app.schemas.auth import AdminCreateUserInput, AdminResetPasswordInput, ImportUsersInput
from app.services.admin_service import AdminService

router = APIRouter(prefix="/admin", tags=["Admin Dashboard"])


@router.post("/users/reset-password", summary="[Admin] Reset Password User")
async def admin_reset_user_password(
    data: AdminResetPasswordInput,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    await svc.reset_user_password(data.nim, data.new_password)
    return response_success(message=f"Password user NIM {data.nim} berhasil direset.")


@router.post("/users", summary="[Admin] Register User Baru")
async def admin_create_user(
    data: AdminCreateUserInput,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    user_data = await svc.create_user(data)
    return response_success(user_data, f"User {user_data['full_name']} berhasil dibuat.")


@router.get("/stats", summary="Get Dashboard Statistics")
async def get_dashboard_stats(
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    return response_success(await svc.get_stats())


@router.get("/users", summary="Get All Users for Admin")
async def get_all_users(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    svc: AdminService = Depends(),
):
    users, total = await svc.get_users(skip, limit)
    return {
        "status": "success",
        "data": users,
        "pagination": {"skip": skip, "limit": limit, "total": total},
    }


@router.get("/projects", summary="Get All Projects for Admin")
async def get_all_projects(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    svc: AdminService = Depends(),
):
    projects, total = await svc.get_projects(skip, limit)
    return {
        "status": "success",
        "data": projects,
        "pagination": {"skip": skip, "limit": limit, "total": total},
    }


@router.get("/showcases", summary="Get All Showcases for Admin")
async def get_all_showcases(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    svc: AdminService = Depends(),
):
    showcases, total = await svc.get_showcases(skip, limit)
    return {
        "status": "success",
        "data": showcases,
        "pagination": {"skip": skip, "limit": limit, "total": total},
    }


@router.get("/tasks", summary="Get All Tasks for Admin")
async def get_all_tasks(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    svc: AdminService = Depends(),
):
    tasks, total = await svc.get_tasks(skip, limit)
    return {
        "status": "success",
        "data": tasks,
        "pagination": {"skip": skip, "limit": limit, "total": total},
    }


@router.get("/applications", summary="Get All Applications for Admin")
async def get_all_applications(
    admin_token: dict = Depends(verify_admin_token),
    skip: int = 0,
    limit: int = 50,
    svc: AdminService = Depends(),
):
    applications, total = await svc.get_applications(skip, limit)
    return {
        "status": "success",
        "data": applications,
        "pagination": {"skip": skip, "limit": limit, "total": total},
    }


@router.get("/analytics", summary="Get Analytics & Big Data Insights")
async def get_analytics(
    admin_token: dict = Depends(verify_admin_token),
    start_date: str = None,
    end_date: str = None,
    faculty: str = None,
    category: str = None,
    granularity: str = "monthly",
    svc: AdminService = Depends(),
):
    return response_success(await svc.get_analytics(start_date, end_date, faculty, category, granularity))


@router.get("/competitions", summary="Get Recent Competitions for Admin")
async def get_recent_competitions(
    admin_token: dict = Depends(verify_admin_token),
    limit: int = 20,
    svc: AdminService = Depends(),
):
    items, total = await svc.get_competitions(limit)
    return response_success({"items": items, "total": total})


@router.post("/users/import", summary="[Admin] Import Batch Mahasiswa via JSON")
async def admin_import_users(
    data: ImportUsersInput,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    result = await svc.import_users(data.users, data.default_password)
    return response_success(
        result,
        f"Berhasil import {result['success_count']} dari {result['total']} mahasiswa.",
    )


@router.delete("/users/{user_id}", summary="Delete User for Admin")
async def delete_user(
    user_id: str,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    await svc.delete_user(user_id)
    return response_success(message="User deleted successfully")


@router.delete("/projects/{project_id}", summary="Delete Project for Admin")
async def delete_project(
    project_id: str,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    await svc.delete_project(project_id)
    return response_success(message="Project deleted successfully")


@router.delete("/showcases/{showcase_id}", summary="Delete Showcase for Admin")
async def delete_showcase(
    showcase_id: str,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    await svc.delete_showcase(showcase_id)
    return response_success(message="Showcase deleted successfully")


@router.delete("/tasks/{task_id}", summary="Delete Task for Admin")
async def delete_task(
    task_id: str,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    await svc.delete_task(task_id)
    return response_success(message="Task deleted successfully")


@router.delete("/applications/{application_id}", summary="Delete Application for Admin")
async def delete_application(
    application_id: str,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    await svc.delete_application(application_id)
    return response_success(message="Application deleted successfully")


@router.delete("/competitions/{competition_id}", summary="Delete Competition for Admin")
async def delete_competition(
    competition_id: str,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    deleted = await svc.delete_competition(competition_id)
    if not deleted:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Competition not found")
    return response_success(message="Competition deleted successfully")


@router.put("/privacy-policy", summary="Update Privacy Policy")
async def update_privacy_policy(
    data: dict,
    admin_token: dict = Depends(verify_admin_token),
    svc: AdminService = Depends(),
):
    content = data.get("content", "")
    await svc.update_privacy_policy(content)
    return response_success(message="Privacy policy updated successfully")
