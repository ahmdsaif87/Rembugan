from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from app.core.response import response_success
from app.core.security import verify_token
from app.schemas.workspace import TaskCreateInput, TaskMoveInput, TaskUpdateInput
from app.services.workspace_service import WorkspaceService

router = APIRouter(prefix="/workspace", tags=["6. Workspace & Kanban"])


@router.get("/", summary="Daftar Workspace Saya")
async def list_workspaces(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    skip = (page - 1) * limit
    data = await svc.list_workspaces(user_token["uid"], skip=skip, limit=limit)
    return response_success(data)


@router.get("/{project_id}", summary="Detail Workspace")
async def get_workspace_detail(
    project_id: int,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    data = await svc.get_detail(project_id, user_token["uid"])
    return response_success(data)


@router.get("/{project_id}/discussions", summary="Diskusi Workspace")
async def get_workspace_discussions(
    project_id: int,
    limit: int = Query(50, ge=1, le=200),
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    data = await svc.get_discussions(project_id, user_token["uid"], limit)
    return response_success(data)


@router.get("/{project_id}/files", summary="Daftar File Workspace")
async def list_workspace_files(
    project_id: int,
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    skip = (page - 1) * limit
    data = await svc.list_files(project_id, user_token["uid"], skip=skip, limit=limit)
    return response_success(data)


@router.post("/{project_id}/files", summary="Upload File ke Workspace")
async def upload_workspace_file(
    project_id: int,
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    uid = user_token["uid"]
    content = await file.read()
    size = len(content)
    if size > 50 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="File terlalu besar (maks 50MB)")
    result = await svc.upload_file(
        project_id, uid, content, file.filename, file.content_type, size
    )
    return response_success(result, f"File '{result['name']}' berhasil diupload!")


@router.delete("/{project_id}/files/{file_id}", summary="Hapus File Workspace")
async def delete_workspace_file(
    project_id: int,
    file_id: int,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    name = await svc.delete_file(project_id, file_id, user_token["uid"])
    return response_success(message=f"File '{name}' berhasil dihapus")


@router.get("/{project_id}/applicants", summary="Daftar Pelamar Workspace")
async def list_workspace_applicants(
    project_id: int,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    data = await svc.list_applicants(project_id, user_token["uid"])
    return response_success(data)


@router.get("/{project_id}/activities", summary="Aktivitas Terbaru Workspace")
async def get_workspace_activities(
    project_id: int,
    limit: int = Query(20, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    data = await svc.get_activities(project_id, user_token["uid"], limit)
    return response_success(data)


@router.post("/{project_id}/tasks", summary="Buat Tugas Baru")
async def create_task(
    project_id: int,
    data: TaskCreateInput,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    user_id = user_token["uid"]
    result = await svc.create_task(
        project_id, user_id, data.title, data.assignee_ids, data.deadline
    )
    return response_success(result, f"Tugas '{result['title']}' berhasil dibuat!")


@router.put("/tasks/{task_id}/move", summary="Geser Kartu Kanban")
async def move_task(
    task_id: int,
    data: TaskMoveInput,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    result = await svc.move_task(task_id, data.status, user_token["uid"])
    return response_success(
        result,
        f"Tugas berhasil dipindah ke kolom '{result['status']}'.",
    )


@router.get("/{project_id}/tasks", summary="Ambil Semua Tugas Proyek")
async def get_project_tasks(
    project_id: int,
    page: int = Query(1, ge=1),
    limit: int = Query(50, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    skip = (page - 1) * limit
    data = await svc.get_tasks(project_id, user_token["uid"], skip=skip, limit=limit)
    return response_success(data)


@router.put("/tasks/{task_id}", summary="Edit Tugas")
async def update_task(
    task_id: int,
    data: TaskUpdateInput,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    user_id = user_token["uid"]
    result = await svc.update_task(
        task_id, user_id, data.title, data.deadline, data.assignee_ids
    )
    return response_success(result, f"Tugas '{result['title']}' berhasil diupdate!")


@router.delete("/tasks/{task_id}", summary="Hapus Tugas")
async def delete_task(
    task_id: int,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    title = await svc.delete_task(task_id, user_token["uid"])
    return response_success(message=f"Tugas '{title}' berhasil dihapus!")


@router.post("/{project_id}/members/{user_id}/kick", summary="Keluarkan anggota dari workspace")
async def kick_member(
    project_id: int,
    user_id: str,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    await svc.kick_member(project_id, user_id, user_token["uid"])
    return response_success(message="Anggota berhasil dikeluarkan dari workspace.")


@router.post("/{project_id}/end", summary="Akhiri Kolaborasi Proyek")
async def end_collaboration(
    project_id: int,
    user_token: dict = Depends(verify_token),
    svc: WorkspaceService = Depends(),
):
    title = await svc.end_collaboration(project_id, user_token["uid"])
    return response_success(
        message=f"Proyek '{title}' berhasil diakhiri dan dipindahkan ke history."
    )
