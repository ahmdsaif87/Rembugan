from fastapi import APIRouter, Depends, Query
from app.core.response import response_success, response_paginated
from app.core.pagination import PageParams
from app.core.security import verify_token
from app.schemas.project import ProjectCreateInput
from app.services.project_service import ProjectService

router = APIRouter(prefix="/projects", tags=["2. Proyek & Kolaborasi"])


@router.post("/create", summary="Buat Proyek Baru")
async def create_project(
    data: ProjectCreateInput,
    user_token: dict = Depends(verify_token),
    service: ProjectService = Depends(ProjectService),
):
    uid = user_token.get("uid")
    project_data = await service.create_project(data, uid)
    return response_success(project_data, "Proyek berhasil dibuat!")


@router.get("/explore", summary="Lihat Semua Proyek yang Terbuka (Match Score)")
async def get_all_projects(
    page_params: PageParams = Depends(),
    category: str = Query(None, description="Filter by category"),
    min_slots: int = Query(None, ge=1, description="Min total slots"),
    max_slots: int = Query(None, ge=1, description="Max total slots"),
    deadline_before: str = Query(None, description="Filter deadline before (ISO datetime)"),
    user_token: dict = Depends(verify_token),
    service: ProjectService = Depends(ProjectService),
):
    uid = user_token.get("uid")
    result = await service.get_explore(uid, page_params)
    return response_paginated(**result)


@router.get("/my-projects", summary="Lihat Proyek Milik Saya")
async def get_my_projects(
    user_token: dict = Depends(verify_token),
    service: ProjectService = Depends(ProjectService),
):
    user_id = user_token.get("uid")
    projects = await service.get_my_projects(user_id)
    return response_success(projects)


@router.get("/{project_id}", summary="Detail Satu Proyek")
async def get_project_detail(
    project_id: int,
    user_token: dict = Depends(verify_token),
    service: ProjectService = Depends(ProjectService),
):
    data = await service.get_detail(project_id)
    return response_success(data)


@router.post("/{project_id}/archive", summary="Archive a project (set status to completed)")
async def archive_project(
    project_id: int,
    user_token: dict = Depends(verify_token),
    service: ProjectService = Depends(ProjectService),
):
    uid = user_token.get("uid")
    data = await service.archive_project(project_id, uid)
    return response_success(data)
