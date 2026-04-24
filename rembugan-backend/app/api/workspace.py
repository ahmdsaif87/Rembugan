from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from zoneinfo import ZoneInfo

from app.core.security import verify_token
from app.core.database import get_db
from app.schemas.workspace import TaskCreateInput, TaskMoveInput

router = APIRouter(prefix="/workspace", tags=["6. Workspace & Kanban"])


@router.post("/{project_id}/tasks", summary="Buat Tugas Baru")
async def create_task(
    project_id: int,
    data: TaskCreateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Buat tugas baru di board Kanban proyek."""
    user_id = user_token.get("uid")

    # Validasi proyek ada
    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    # Validasi user adalah member proyek
    member = await db.projectmember.find_first(
        where={"project_id": project_id, "user_id": user_id}
    )
    if not member:
        raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

    task = await db.task.create(
        data={
            "project_id": project_id,
            "title": data.title,
            "assignee_id": data.assignee_id,
            "status": "todo",
        },
        include={"assignee": True},
    )

    return {
        "status": "success",
        "message": f"Tugas '{task.title}' berhasil dibuat!",
        "data": {
            "id": task.id, "title": task.title, "status": task.status,
            "assignee_name": task.assignee.full_name if task.assignee else None,
            "created_at": task.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        },
    }


@router.put("/tasks/{task_id}/move", summary="Geser Kartu Kanban")
async def move_task(
    task_id: int,
    data: TaskMoveInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Pindahkan tugas ke kolom Kanban lain (todo/doing/done)."""
    # Validasi task ada
    task = await db.task.find_unique(where={"id": task_id})
    if not task:
        raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

    updated = await db.task.update(
        where={"id": task_id},
        data={"status": data.status},
    )

    return {
        "status": "success",
        "message": f"Tugas berhasil dipindah ke kolom '{updated.status}'.",
        "data": {"id": updated.id, "title": updated.title, "status": updated.status},
    }


@router.get("/{project_id}/tasks", summary="Ambil Semua Tugas Proyek")
async def get_project_tasks(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil semua tugas di board Kanban proyek, dikelompokkan per status."""
    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    tasks = await db.task.find_many(
        where={"project_id": project_id},
        include={"assignee": True},
        order={"created_at": "asc"},
    )

    board = {"todo": [], "doing": [], "done": []}
    for t in tasks:
        item = {
            "id": t.id, "title": t.title, "status": t.status,
            "assignee_name": t.assignee.full_name if t.assignee else None,
            "created_at": t.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        }
        if t.status in board:
            board[t.status].append(item)

    return {"status": "success", "project_id": project_id, "board": board}