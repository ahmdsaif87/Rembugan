from dataclasses import dataclass
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.dates import tz_iso
from app.core.tasks import fire_and_forget
from datetime import datetime, timedelta, timezone
from app.core.constants import (
    APP_PENDING, TASK_TODO, TASK_DOING, TASK_DONE,
    PJ_COMPLETED, ROLE_ANGGOTA, NOTIF_FILE_UPLOADED, NOTIF_TASK_ASSIGNED,
)
from app.services.storage import upload_image_to_cloudinary
from app.services.chat_manager import manager
from app.services.notification import notify


@dataclass
class WorkspaceService:
    db: Prisma = Depends(get_db)

    async def _get_user_role(self, project_id: int, user_id: str) -> tuple:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            return None, None
        if project.owner_id == user_id:
            return project, "Pemilik"
        member = await self.db.projectmember.find_first(
            where={"project_id": project_id, "user_id": user_id}
        )
        if member:
            return project, member.role
        return None, None

    def _format_relative_time(self, dt: datetime) -> str:
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
        self, project, user_id: str, user_role: str | None
    ) -> dict:
        project_full = await self.db.project.find_unique(
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
                "is_online": manager.is_online(m.user_id),
                "photo_url": m.user.photo_url,
            })

        total_tasks = len(project_full.tasks or [])
        done_tasks = sum(1 for t in (project_full.tasks or []) if t.status == TASK_DONE)
        applicant_count = len(project_full.applications or [])

        last_msg = await self.db.message.find_first(
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
            sender = await self.db.user.find_unique(where={"id": last_msg.sender_id})
            sender_name = sender.full_name if sender else "Seseorang"
            activity_cue = f"{sender_name}: {last_msg.content[:60]}"
        elif last_task:
            last_activity_time = last_task.created_at
            activity_cue = f"Task '{last_task.title}' ditambahkan"
        elif is_owned:
            activity_cue = "Proyek dibuat"

        last_activity_str = self._format_relative_time(last_activity_time)

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

    async def _build_workspace_data_fast(
        self, project, user_id: str, user_role: str | None,
        members: list, tasks: list, pending_apps: list,
        latest_msg_info: tuple | None,
    ) -> dict:
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
                "is_online": manager.is_online(m.user_id),
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

        last_activity_str = self._format_relative_time(last_activity_time)

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

    # ── Public API ──

    async def list_workspaces(self, user_id: str) -> list[dict]:
        owned = await self.db.project.find_many(
            where={"owner_id": user_id},
            order={"created_at": "desc"},
        )
        memberships = await self.db.projectmember.find_many(
            where={"user_id": user_id},
            include={"project": True},
        )

        project_map = {}
        for p in owned:
            project_map[p.id] = (p, "Pemilik")
        for m in memberships:
            if m.project.id not in project_map:
                project_map[m.project.id] = (m.project, m.role)

        project_ids = list(project_map.keys())
        if not project_ids:
            return []

        all_members = await self.db.projectmember.find_many(
            where={"project_id": {"in": project_ids}},
            include={"user": True},
        )
        all_tasks = await self.db.task.find_many(
            where={"project_id": {"in": project_ids}},
        )
        all_apps = await self.db.projectapplication.find_many(
            where={"project_id": {"in": project_ids}, "status": APP_PENDING},
        )
        all_msgs = await self.db.message.find_many(
            where={"project_id": {"in": project_ids}},
            order={"created_at": "desc"},
            include={"sender": True},
        )
        all_latest_msgs: dict[int, tuple] = {}
        seen = set()
        for m in all_msgs:
            if m.project_id not in seen:
                seen.add(m.project_id)
                all_latest_msgs[m.project_id] = (m, m.sender.full_name if m.sender else "Seseorang")

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
            data = await self._build_workspace_data_fast(
                project, user_id, role,
                members=members_by_pid.get(pid, []),
                tasks=tasks_by_pid.get(pid, []),
                pending_apps=apps_by_pid.get(pid, []),
                latest_msg_info=all_latest_msgs.get(pid),
            )
            result.append(data)
        return result

    async def get_detail(self, project_id: int, user_id: str) -> dict:
        project, role = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")
        return await self._build_workspace_data(project, user_id, role)

    async def get_discussions(self, project_id: int, user_id: str, limit: int) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        messages = await self.db.message.find_many(
            where={"project_id": project_id},
            order={"created_at": "desc"},
            take=limit,
            include={"sender": True},
        )

        result = []
        for m in reversed(messages):
            attachment_data = None
            if m.attachment_url:
                attachment_data = {
                    "url": m.attachment_url,
                    "name": m.attachment_name,
                    "size": m.attachment_size,
                }
            result.append({
                "id": m.id,
                "sender": m.sender.full_name if m.sender else "System",
                "sender_id": m.sender_id,
                "body": m.content,
                "type": m.type,
                "time": tz_iso(m.created_at),
                "is_me": m.sender_id == user_id,
                "is_system": m.type == "system",
                "reply_to": m.reply_to_id,
                "attachment": attachment_data,
            })
        return result

    async def list_files(self, project_id: int, user_id: str) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        files = await self.db.projectfile.find_many(
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
                "date": self._format_relative_time(f.created_at),
                "size": size_str,
                "type": ext,
                "url": f.url,
            })
        return result

    async def upload_file(
        self, project_id: int, user_id: str,
        file_content: bytes, filename: str, content_type: str, size: int
    ) -> dict:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        url = await upload_image_to_cloudinary(file_content, folder_name="rembugan_workspace_files")

        pf = await self.db.projectfile.create(
            data={
                "project_id": project_id,
                "user_id": user_id,
                "name": filename or "untitled",
                "url": url,
                "size": size,
                "mime_type": content_type,
            },
            include={"uploader": True},
        )

        room_id = str(project_id)
        fire_and_forget(
            self.db.message.create(data={
                "content": "",
                "type": "file",
                "sender_id": user_id,
                "project_id": project_id,
                "attachment_name": pf.name,
                "attachment_url": pf.url,
                "attachment_size": pf.size,
            }),
            "save_file_message"
        )

        fire_and_forget(
            manager.broadcast({
                "sender_id": user_id,
                "sender_name": pf.uploader.full_name,
                "sender_photo_url": pf.uploader.photo_url,
                "text": "",
                "type": "file",
                "attachment_url": pf.url,
                "attachment_name": pf.name,
                "attachment_size": pf.size,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }, room_id),
            "broadcast_file_upload"
        )

        members = await self.db.projectmember.find_many(where={"project_id": project_id})
        uploader = pf.uploader
        for m in members:
            if m.user_id != user_id:
                fire_and_forget(
                    notify(self.db, m.user_id, NOTIF_FILE_UPLOADED,
                           f"File baru di {project.title}",
                           f"{uploader.full_name} mengunggah {pf.name}",
                           f"/workspace/{project_id}"),
                    "notify_file_upload"
                )

        return {
            "id": pf.id,
            "name": pf.name,
            "uploader": pf.uploader.full_name,
            "size": f"{pf.size / 1024:.0f} KB" if pf.size else "Unknown",
            "type": pf.name.split(".")[-1] if "." in pf.name else "file",
            "url": pf.url,
        }

    async def delete_file(self, project_id: int, file_id: int, user_id: str) -> str:
        project, role = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        pf = await self.db.projectfile.find_first(
            where={"id": file_id, "project_id": project_id}
        )
        if not pf:
            raise HTTPException(status_code=404, detail="File tidak ditemukan")

        if pf.user_id != user_id and project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Tidak bisa menghapus file ini")

        await self.db.projectfile.delete(where={"id": file_id})
        return pf.name

    async def list_applicants(self, project_id: int, user_id: str) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya pemilik yang bisa melihat pelamar")

        apps = await self.db.projectapplication.find_many(
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
        return result

    async def get_activities(self, project_id: int, user_id: str, limit: int) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        activities = []

        messages = await self.db.message.find_many(
            where={"project_id": project_id},
            order={"created_at": "desc"},
            take=limit,
            include={"sender": True},
        )
        for m in messages:
            activities.append({
                "text": f"{m.sender.full_name} mengirim pesan",
                "time": self._format_relative_time(m.created_at),
                "workspace": project.title,
                "type": "message",
                "created_at": m.created_at.isoformat(),
            })

        tasks = await self.db.task.find_many(
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
                "time": self._format_relative_time(t.created_at),
                "workspace": project.title,
                "type": "task",
                "created_at": t.created_at.isoformat(),
            })

        files = await self.db.projectfile.find_many(
            where={"project_id": project_id},
            order={"created_at": "desc"},
            take=limit,
            include={"uploader": True},
        )
        for f in files:
            activities.append({
                "text": f"{f.uploader.full_name} mengupload {f.name}",
                "time": self._format_relative_time(f.created_at),
                "workspace": project.title,
                "type": "file",
                "created_at": f.created_at.isoformat(),
            })

        activities.sort(key=lambda x: x["created_at"], reverse=True)
        activities = activities[:limit]

        for a in activities:
            del a["created_at"]

        return activities

    async def create_task(
        self, project_id: int, user_id: str,
        title: str, assignee_ids: list[str], deadline: str | None
    ) -> dict:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        member = await self.db.projectmember.find_first(
            where={"project_id": project_id, "user_id": user_id}
        )
        if not member and project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

        deadline_dt = datetime.fromisoformat(deadline) if deadline else None
        task = await self.db.task.create(
            data={
                "project_id": project_id,
                "title": title,
                "status": TASK_TODO,
                "deadline": deadline_dt,
                "assignees": {
                    "create": [
                        {"user_id": uid} for uid in assignee_ids
                    ]
                } if assignee_ids else {},
            },
            include={"assignees": {"include": {"user": True}}},
        )

        for assignee in task.assignees:
            if assignee.user_id != user_id:
                await notify(
                    db=self.db,
                    user_id=assignee.user_id,
                    type_=NOTIF_TASK_ASSIGNED,
                    title="Tugas Baru",
                    content=f"Kamu ditugaskan: {task.title}",
                    link=f"/workspace/{project_id}",
                )

        return {
            "id": task.id,
            "title": task.title,
            "status": task.status,
            "assignees": [
                {"id": a.user_id, "name": a.user.full_name}
                for a in task.assignees
            ],
            "deadline": task.deadline.isoformat() if task.deadline else None,
            "created_at": tz_iso(task.created_at),
        }

    async def move_task(self, task_id: int, status: str) -> dict:
        task = await self.db.task.find_unique(where={"id": task_id})
        if not task:
            raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

        updated = await self.db.task.update(
            where={"id": task_id},
            data={"status": status},
        )

        return {
            "id": updated.id,
            "title": updated.title,
            "status": updated.status,
        }

    async def get_tasks(self, project_id: int, user_id: str) -> dict:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        tasks = await self.db.task.find_many(
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

        return {"project_id": project_id, "board": board}

    async def update_task(
        self, task_id: int, user_id: str,
        title: str | None, deadline: str | None, assignee_ids: list[str] | None
    ) -> dict:
        task = await self.db.task.find_unique(
            where={"id": task_id},
            include={"project": True},
        )
        if not task:
            raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

        member = await self.db.projectmember.find_first(
            where={"project_id": task.project_id, "user_id": user_id}
        )
        if not member and task.project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

        update_data = {}
        if title is not None:
            update_data["title"] = title
        if deadline is not None:
            update_data["deadline"] = datetime.fromisoformat(deadline)

        if assignee_ids is not None:
            await self.db.taskassignee.delete_many(where={"task_id": task_id})
            for uid in assignee_ids:
                await self.db.taskassignee.create(data={"task_id": task_id, "user_id": uid})
                if uid != user_id:
                    await notify(
                        db=self.db,
                        user_id=uid,
                        type_=NOTIF_TASK_ASSIGNED,
                        title="Tugas Diperbarui",
                        content=f"Kamu ditugaskan: {task.title}",
                        link=f"/workspace/{task.project_id}",
                    )

        updated = await self.db.task.update(
            where={"id": task_id},
            data=update_data,
            include={"assignees": {"include": {"user": True}}},
        )

        return {
            "id": updated.id,
            "title": updated.title,
            "status": updated.status,
            "assignees": [
                {"id": a.user_id, "name": a.user.full_name}
                for a in updated.assignees
            ],
            "deadline": updated.deadline.isoformat() if updated.deadline else None,
        }

    async def delete_task(self, task_id: int, user_id: str) -> str:
        task = await self.db.task.find_unique(
            where={"id": task_id},
            include={"project": True},
        )
        if not task:
            raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

        member = await self.db.projectmember.find_first(
            where={"project_id": task.project_id, "user_id": user_id}
        )
        if not member and task.project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

        await self.db.task.delete(where={"id": task_id})
        return task.title

    async def kick_member(self, project_id: int, target_user_id: str, requester_id: str) -> None:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        if project.owner_id != requester_id:
            raise HTTPException(status_code=403, detail="Hanya ketua proyek yang bisa mengeluarkan anggota.")

        if target_user_id == requester_id:
            raise HTTPException(status_code=400, detail="Tidak bisa mengeluarkan diri sendiri.")

        member = await self.db.projectmember.find_first(
            where={"project_id": project_id, "user_id": target_user_id}
        )
        if not member:
            raise HTTPException(status_code=404, detail="Anggota tidak ditemukan.")

        await self.db.projectmember.delete(where={"id": member.id})

    async def end_collaboration(self, project_id: int, user_id: str) -> str:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya ketua proyek yang bisa mengakhiri kolaborasi.")

        updated = await self.db.project.update(
            where={"id": project_id},
            data={"status": PJ_COMPLETED},
        )
        return updated.title
