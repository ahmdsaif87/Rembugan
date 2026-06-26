from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File
from prisma import Prisma
from app.core.dates import tz_iso
from datetime import datetime, timedelta

from app.core.security import verify_token
from app.core.database import get_db
from app.core.constants import APP_PENDING, TASK_TODO, TASK_DOING, TASK_DONE, PJ_COMPLETED, ROLE_ANGGOTA
from app.schemas.workspace import TaskCreateInput, TaskMoveInput, TaskUpdateInput
from app.services.storage import upload_image_to_cloudinary

router = APIRouter(prefix="/workspace", tags=["6. Workspace & Kanban"])


async def _get_user_role_in_project(db: Prisma, project_id: int, user_id: str):
    """Helper: cek apakah user owner atau member project, return role string."""
    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        return None, None
    if project.owner_id == user_id:
        return project, "Pemilik"
    member = await db.projectmember.find_first(
        where={"project_id": project_id, "user_id": user_id}
    )
    if member:
        return project, member.role
    return None, None


def _format_relative_time(dt: datetime) -> str:
    now = datetime.now(dt.tzinfo) if dt.tzinfo else datetime.now()
    diff = now - dt
    if diff < timedelta(minutes=1):
        return "Baru saja"
    if diff < timedelta(hours=1):
        m = int(diff.total_seconds() / 60)
        return f"{m} menit lalu"
    if diff < timedelta(days=1):
        h = int(diff.total_seconds() / 3600)
        return f"{h} jam lalu"
    if diff < timedelta(days=7):
        d = diff.days
        return f"{d} hari lalu"
    return dt.strftime("%d %b")


async def _build_workspace_data(
    db: Prisma, project, user_id: str, user_role: str | None
):
    """Build response for a single workspace (detail endpoint)."""
    # Load semua data sekaligus via include
    project_full = await db.project.find_unique(
        where={"id": project.id},
        include={
            "members": {"include": {"user": True}},
            "tasks": True,
            "applications": {"where": {"status": APP_PENDING}},
        },
    )
    if not project_full:
        return {}

    is_owned = project_full.owner_id == user_id

    member_list = []
    for m in project_full.members or []:
        initials = "".join(
            [w[0].upper() for w in m.user.full_name.split()[:2]]
        ) or "?"
        member_list.append({
            "user_id": m.user_id,
            "name": m.user.full_name,
            "initials": initials,
            "role": m.role,
            "is_online": False,
            "photo_url": m.user.photo_url,
        })

    total_tasks = len(project_full.tasks or [])
    done_tasks = sum(1 for t in (project_full.tasks or []) if t.status == TASK_DONE)
    applicant_count = len(project_full.applications or [])

    last_msg = await db.message.find_first(
        where={"project_id": project.id},
        order={"created_at": "desc"},
    )
    last_task = next(
        (t for t in sorted(project_full.tasks or [], key=lambda x: x.created_at, reverse=True)),
        None,
    )
    last_activity_time = project.created_at
    activity_cue = None

    if last_msg:
        last_activity_time = last_msg.created_at
        sender_name = last_msg.content.split(":")[0] if ":" in last_msg.content else "Seseorang"
        # Ambil sender name
        sender = await db.user.find_unique(where={"id": last_msg.sender_id})
        sender_name = sender.full_name if sender else "Seseorang"
        activity_cue = f"{sender_name}: {last_msg.content[:60]}"
    elif last_task:
        last_activity_time = last_task.created_at
        activity_cue = f"Task '{last_task.title}' ditambahkan"
    elif is_owned:
        activity_cue = "Proyek dibuat"

    last_activity_str = _format_relative_time(last_activity_time)

    urgency = None
    if project.deadline:
        now = datetime.now(project.deadline.tzinfo) if project.deadline.tzinfo else datetime.now()
        if project.deadline < now:
            urgency = "overdue"
        elif project.deadline - now < timedelta(days=3):
            urgency = "deadline"

    return {
        "id": str(project_full.id),
        "name": project_full.title,
        "description": project_full.description,
        "user_role": user_role or ROLE_ANGGOTA,
        "total_tasks": total_tasks,
        "done_tasks": done_tasks,
        "member_count": len(member_list),
        "members": member_list,
        "last_activity": last_activity_str,
        "is_owned": is_owned,
        "applicants": applicant_count,
        "unread_count": 0,
        "activity_cue": activity_cue,
        "urgency": urgency,
        "created_at": tz_iso(project.created_at),
        "deadline": project.deadline.isoformat() if project.deadline else None,
    }


@router.get("/", summary="Daftar Workspace Saya")
async def list_workspaces(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil semua workspace milik/ikuti user — batch-loaded."""
    uid = user_token.get("uid")

    owned = await db.project.find_many(
        where={"owner_id": uid},
        order={"created_at": "desc"},
    )
    memberships = await db.projectmember.find_many(
        where={"user_id": uid},
        include={"project": True},
    )

    # Kumpulkan semua project IDs
    owned_set = {p.id: p for p in owned}
    project_map = {}
    for p in owned:
        project_map[p.id] = (p, "Pemilik")
    for m in memberships:
        if m.project.id not in project_map:
            project_map[m.project.id] = (m.project, m.role)

    project_ids = list(project_map.keys())
    if not project_ids:
        return {"status": "success", "data": []}

    # Batch-load semua data terkait untuk semua project dalam 4 query
    all_members = await db.projectmember.find_many(
        where={"project_id": {"in": project_ids}},
        include={"user": True},
    )
    all_tasks = await db.task.find_many(
        where={"project_id": {"in": project_ids}},
    )
    all_apps = await db.projectapplication.find_many(
        where={"project_id": {"in": project_ids}, "status": APP_PENDING},
    )
    # Batch-load latest message per project — 1 query total
    all_latest_msgs: dict[int, tuple] = {}
    all_msgs = await db.message.find_many(
        where={"project_id": {"in": project_ids}},
        order={"created_at": "desc"},
        include={"sender": True},
    )
    seen = set()
    for m in all_msgs:
        if m.project_id not in seen:
            seen.add(m.project_id)
            all_latest_msgs[m.project_id] = (m, m.sender.full_name if m.sender else "Seseorang")

    # Group data by project_id
    members_by_pid: dict[int, list] = {}
    for m in all_members:
        members_by_pid.setdefault(m.project_id, []).append(m)
    tasks_by_pid: dict[int, list] = {}
    for t in all_tasks:
        tasks_by_pid.setdefault(t.project_id, []).append(t)
    apps_by_pid: dict[int, list] = {}
    for a in all_apps:
        apps_by_pid.setdefault(a.project_id, []).append(a)

    result = []
    for pid, (project, role) in project_map.items():
        # Panggil helper yang menerima data pre-loaded
        data = await _build_workspace_data_fast(
            project, uid, role,
            members=members_by_pid.get(pid, []),
            tasks=tasks_by_pid.get(pid, []),
            pending_apps=apps_by_pid.get(pid, []),
            latest_msg_info=all_latest_msgs.get(pid),
        )
        result.append(data)

    return {"status": "success", "data": result}


async def _build_workspace_data_fast(
    project, user_id: str, user_role: str | None,
    members: list, tasks: list, pending_apps: list,
    latest_msg_info: tuple | None,
):
    """Build workspace data from PRE-LOADED data (no additional DB queries)."""
    is_owned = project.owner_id == user_id

    member_list = []
    for m in members:
        initials = "".join(
            [w[0].upper() for w in m.user.full_name.split()[:2]]
        ) or "?"
        member_list.append({
            "user_id": m.user_id,
            "name": m.user.full_name,
            "initials": initials,
            "role": m.role,
            "is_online": False,
            "photo_url": m.user.photo_url,
        })

    total_tasks = len(tasks)
    done_tasks = sum(1 for t in tasks if t.status == TASK_DONE)
    applicant_count = len(pending_apps)

    last_activity_time = project.created_at
    activity_cue = None

    if latest_msg_info:
        msg, sender_name = latest_msg_info
        last_activity_time = msg.created_at
        activity_cue = f"{sender_name}: {msg.content[:60]}"
    else:
        last_task = tasks[-1] if tasks else None
        if last_task:
            last_activity_time = last_task.created_at
            activity_cue = f"Task '{last_task.title}' ditambahkan"
        elif is_owned:
            activity_cue = "Proyek dibuat"

    last_activity_str = _format_relative_time(last_activity_time)

    urgency = None
    if project.deadline:
        now = datetime.now(project.deadline.tzinfo) if project.deadline.tzinfo else datetime.now()
        if project.deadline < now:
            urgency = "overdue"
        elif project.deadline - now < timedelta(days=3):
            urgency = "deadline"

    return {
        "id": str(project.id),
        "name": project.title,
        "description": project.description,
        "user_role": user_role or ROLE_ANGGOTA,
        "total_tasks": total_tasks,
        "done_tasks": done_tasks,
        "member_count": len(member_list),
        "members": member_list,
        "last_activity": last_activity_str,
        "is_owned": is_owned,
        "applicants": applicant_count,
        "unread_count": 0,
        "activity_cue": activity_cue,
        "urgency": urgency,
        "created_at": tz_iso(project.created_at),
        "deadline": project.deadline.isoformat() if project.deadline else None,
    }


@router.get("/{project_id}", summary="Detail Workspace")
async def get_workspace_detail(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil detail workspace lengkap."""
    uid = user_token.get("uid")
    project, role = await _get_user_role_in_project(db, project_id, uid)

    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    data = await _build_workspace_data(db, project, uid, role)

    return {"status": "success", "data": data}


# ── Discussions ──

@router.get("/{project_id}/discussions", summary="Diskusi Workspace")
async def get_workspace_discussions(
    project_id: int,
    limit: int = Query(50, ge=1, le=200),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil riwayat chat diskusi workspace."""
    uid = user_token.get("uid")
    project, _ = await _get_user_role_in_project(db, project_id, uid)
    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    messages = await db.message.find_many(
        where={"project_id": project_id},
        order={"created_at": "desc"},
        take=limit,
        include={"sender": True},
    )

    result = []
    for m in reversed(messages):
        result.append({
            "id": m.id,
            "sender": m.sender.full_name,
            "sender_id": m.sender_id,
            "body": m.content,
            "time": tz_iso(m.created_at),
            "is_me": m.sender_id == uid,
            "is_system": False,
            "reply_to": None,
            "attachment": None,
        })

    return {"status": "success", "data": result}


# ── Files ──

@router.get("/{project_id}/files", summary="Daftar File Workspace")
async def list_workspace_files(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil daftar file yang diupload di workspace."""
    uid = user_token.get("uid")
    project, _ = await _get_user_role_in_project(db, project_id, uid)
    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    files = await db.projectfile.find_many(
        where={"project_id": project_id},
        order={"created_at": "desc"},
        include={"uploader": True},
    )

    result = []
    for f in files:
        size_str = f"{f.size / 1024:.0f} KB" if f.size else "Unknown"
        ext = f.name.split(".")[-1] if "." in f.name else "file"
        result.append({
            "id": f.id,
            "name": f.name,
            "uploader": f.uploader.full_name,
            "date": _format_relative_time(f.created_at),
            "size": size_str,
            "type": ext,
            "url": f.url,
        })

    return {"status": "success", "data": result}


@router.post("/{project_id}/files", summary="Upload File ke Workspace")
async def upload_workspace_file(
    project_id: int,
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Upload file ke workspace (disimpan di database sebagai URL)."""
    uid = user_token.get("uid")
    project, _ = await _get_user_role_in_project(db, project_id, uid)
    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    content = await file.read()
    size = len(content)

    # Upload ke Cloudinary
    url = upload_image_to_cloudinary(content, folder_name="rembugan_workspace_files")

    pf = await db.projectfile.create(
        data={
            "project_id": project_id,
            "user_id": uid,
            "name": file.filename or "untitled",
            "url": url,
            "size": size,
            "mime_type": file.content_type,
        },
        include={"uploader": True},
    )

    return {
        "status": "success",
        "message": f"File '{pf.name}' berhasil diupload!",
        "data": {
            "id": pf.id,
            "name": pf.name,
            "uploader": pf.uploader.full_name,
            "size": f"{pf.size / 1024:.0f} KB" if pf.size else "Unknown",
            "type": pf.name.split(".")[-1] if "." in pf.name else "file",
            "url": pf.url,
        },
    }


@router.delete("/{project_id}/files/{file_id}", summary="Hapus File Workspace")
async def delete_workspace_file(
    project_id: int,
    file_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Hapus file dari workspace."""
    uid = user_token.get("uid")
    project, role = await _get_user_role_in_project(db, project_id, uid)
    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    pf = await db.projectfile.find_first(
        where={"id": file_id, "project_id": project_id}
    )
    if not pf:
        raise HTTPException(status_code=404, detail="File tidak ditemukan")

    if pf.user_id != uid and project.owner_id != uid:
        raise HTTPException(status_code=403, detail="Tidak bisa menghapus file ini")

    await db.projectfile.delete(where={"id": file_id})

    return {"status": "success", "message": f"File '{pf.name}' berhasil dihapus"}


# ── Applicants ──

@router.get("/{project_id}/applicants", summary="Daftar Pelamar Workspace")
async def list_workspace_applicants(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil daftar pelamar yang pending."""
    uid = user_token.get("uid")
    project, _ = await _get_user_role_in_project(db, project_id, uid)
    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    if project.owner_id != uid:
        raise HTTPException(status_code=403, detail="Hanya pemilik yang bisa melihat pelamar")

    apps = await db.projectapplication.find_many(
        where={"project_id": project_id, "status": APP_PENDING},
        include={"applicant": {"include": {"skills": {"include": {"skill": True}}}}},
        order={"applied_at": "desc"},
    )

    result = []
    for a in apps:
        result.append({
            "id": str(a.id),
            "workspace_id": str(project_id),
            "name": a.applicant.full_name,
            "role": ROLE_ANGGOTA,
            "note": "",
            "skills": [s.skill.name for s in a.applicant.skills],
            "applied_at": tz_iso(a.applied_at),
        })

    return {"status": "success", "data": result}


# ── Activities ──

@router.get("/{project_id}/activities", summary="Aktivitas Terbaru Workspace")
async def get_workspace_activities(
    project_id: int,
    limit: int = Query(20, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil aktivitas terbaru di workspace."""
    uid = user_token.get("uid")
    project, _ = await _get_user_role_in_project(db, project_id, uid)
    if not project:
        raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

    activities = []

    messages = await db.message.find_many(
        where={"project_id": project_id},
        order={"created_at": "desc"},
        take=limit,
        include={"sender": True},
    )
    for m in messages:
        activities.append({
            "text": f"{m.sender.full_name} mengirim pesan",
            "time": _format_relative_time(m.created_at),
            "workspace": project.title,
            "type": "message",
            "created_at": m.created_at.isoformat(),
        })

    tasks = await db.task.find_many(
        where={"project_id": project_id},
        order={"created_at": "desc"},
        take=limit,
        include={"assignees": {"include": {"user": True}}},
    )
    for t in tasks:
        status_text = {
            TASK_TODO: "ditambahkan",
            TASK_DOING: "sedang dikerjakan",
            TASK_DONE: "diselesaikan",
        }
        actions = status_text.get(t.status, "diupdate")
        names = [a.user.full_name for a in t.assignees] if t.assignees else ["Seseorang"]
        assignee_str = ", ".join(names)
        activities.append({
            "text": f"Task '{t.title}' {actions} oleh {assignee_str}",
            "time": _format_relative_time(t.created_at),
            "workspace": project.title,
            "type": "task",
            "created_at": t.created_at.isoformat(),
        })

    files = await db.projectfile.find_many(
        where={"project_id": project_id},
        order={"created_at": "desc"},
        take=limit,
        include={"uploader": True},
    )
    for f in files:
        activities.append({
            "text": f"{f.uploader.full_name} mengupload {f.name}",
            "time": _format_relative_time(f.created_at),
            "workspace": project.title,
            "type": "file",
            "created_at": f.created_at.isoformat(),
        })

    activities.sort(key=lambda x: x["created_at"], reverse=True)
    activities = activities[:limit]

    for a in activities:
        del a["created_at"]

    return {"status": "success", "data": activities}


# ── Existing Task Endpoints ──

@router.post("/{project_id}/tasks", summary="Buat Tugas Baru")
async def create_task(
    project_id: int,
    data: TaskCreateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Buat tugas baru di board Kanban proyek."""
    user_id = user_token.get("uid")

    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    member = await db.projectmember.find_first(
        where={"project_id": project_id, "user_id": user_id}
    )
    if not member and project.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

    deadline_dt = datetime.fromisoformat(data.deadline) if data.deadline else None
    task = await db.task.create(
        data={
            "project_id": project_id,
            "title": data.title,
            "status": TASK_TODO,
            "deadline": deadline_dt,
            "assignees": {
                "create": [
                    {"user_id": uid} for uid in data.assignee_ids
                ]
            } if data.assignee_ids else {},
        },
        include={"assignees": {"include": {"user": True}}},
    )

    return {
        "status": "success",
        "message": f"Tugas '{task.title}' berhasil dibuat!",
        "data": {
            "id": task.id,
            "title": task.title,
            "status": task.status,
            "assignees": [
                {"id": a.user_id, "name": a.user.full_name}
                for a in task.assignees
            ],
            "deadline": task.deadline.isoformat() if task.deadline else None,
            "created_at": tz_iso(task.created_at),
        },
    }


@router.put("/tasks/{task_id}/move", summary="Geser Kartu Kanban")
async def move_task(
    task_id: int,
    data: TaskMoveInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
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
    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    tasks = await db.task.find_many(
        where={"project_id": project_id},
        include={"assignees": {"include": {"user": True}}},
        order={"created_at": "asc"},
    )

    board = {TASK_TODO: [], TASK_DOING: [], TASK_DONE: []}
    for t in tasks:
        item = {
            "id": t.id,
            "title": t.title,
            "status": t.status,
            "assignees": [
                {"id": a.user_id, "name": a.user.full_name}
                for a in t.assignees
            ],
            "deadline": t.deadline.isoformat() if t.deadline else None,
            "created_at": tz_iso(t.created_at),
        }
        if t.status in board:
            board[t.status].append(item)

    return {"status": "success", "project_id": project_id, "board": board}


@router.put("/tasks/{task_id}", summary="Edit Tugas")
async def update_task(
    task_id: int,
    data: TaskUpdateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    user_id = user_token.get("uid")
    task = await db.task.find_unique(
        where={"id": task_id},
        include={"project": True},
    )
    if not task:
        raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

    member = await db.projectmember.find_first(
        where={"project_id": task.project_id, "user_id": user_id}
    )
    if not member and task.project.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

    update_data = {}
    if data.title is not None:
        update_data["title"] = data.title
    if data.deadline is not None:
        update_data["deadline"] = datetime.fromisoformat(data.deadline)

    if data.assignee_ids is not None:
        await db.taskassignee.delete_many(where={"task_id": task_id})
        for uid in data.assignee_ids:
            await db.taskassignee.create(data={"task_id": task_id, "user_id": uid})

    updated = await db.task.update(
        where={"id": task_id},
        data=update_data,
        include={"assignees": {"include": {"user": True}}},
    )

    return {
        "status": "success",
        "message": f"Tugas '{updated.title}' berhasil diupdate!",
        "data": {
            "id": updated.id,
            "title": updated.title,
            "status": updated.status,
            "assignees": [
                {"id": a.user_id, "name": a.user.full_name}
                for a in updated.assignees
            ],
            "deadline": updated.deadline.isoformat() if updated.deadline else None,
        },
    }


@router.delete("/tasks/{task_id}", summary="Hapus Tugas")
async def delete_task(
    task_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    user_id = user_token.get("uid")
    task = await db.task.find_unique(
        where={"id": task_id},
        include={"project": True},
    )
    if not task:
        raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

    member = await db.projectmember.find_first(
        where={"project_id": task.project_id, "user_id": user_id}
    )
    if not member and task.project.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

    await db.task.delete(where={"id": task_id})

    return {"status": "success", "message": f"Tugas '{task.title}' berhasil dihapus!"}


@router.post("/{project_id}/end", summary="Akhiri Kolaborasi Proyek")
async def end_collaboration(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    user_id = user_token.get("uid")

    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    if project.owner_id != user_id:
        raise HTTPException(status_code=403, detail="Hanya ketua proyek yang bisa mengakhiri kolaborasi.")

    updated = await db.project.update(
        where={"id": project_id},
        data={"status": PJ_COMPLETED},
    )

    return {
        "status": "success",
        "message": f"Proyek '{updated.title}' berhasil diakhiri dan dipindahkan ke history.",
    }
