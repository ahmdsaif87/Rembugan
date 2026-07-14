from dataclasses import dataclass
from fastapi import Depends, HTTPException
from sqlalchemy import select, or_, and_, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session, async_session_factory
from app.core.dates import tz_iso
from app.core.tasks import fire_and_forget
from datetime import datetime, timedelta, timezone
from app.core.constants import (
    APP_PENDING, TASK_TODO, TASK_DOING, TASK_DONE,
    PJ_COMPLETED, ROLE_ANGGOTA, NOTIF_FILE_UPLOADED, NOTIF_TASK_ASSIGNED,
)
from app.models import User, Project, ProjectMember, ProjectApplication, Skill
from app.models.collaboration import Task, TaskAssignee
from app.models.social import ProjectFile
from app.models.chat import Message
from app.services.storage import upload_image_to_cloudinary
from app.services.chat_manager import manager
from app.services.notification import notify


def _parse_dt(value: str) -> datetime | None:
    dt = datetime.fromisoformat(value)
    if isinstance(dt, datetime):
        return dt
    from datetime import date
    if isinstance(dt, date):
        return datetime.combine(dt, datetime.min.time())
    return dt


@dataclass
class WorkspaceService:
    session: AsyncSession = Depends(get_db_session)

    async def _get_user_role(self, project_id: int, user_id: str) -> tuple:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            return None, None
        if project.owner_id == user_id:
            return project, "Pemilik"
        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == project_id,
                ProjectMember.user_id == user_id,
            )
        )
        member = result.scalar_one_or_none()
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
        result = await self.session.execute(
            select(Project).where(Project.id == project.id)
        )
        project_full = result.scalar_one_or_none()
        if not project_full:
            return {}

        is_owned = project_full.owner_id == user_id

        # Fetch members with users
        result = await self.session.execute(
            select(ProjectMember).where(ProjectMember.project_id == project.id)
        )
        members_raw = result.scalars().all()
        member_user_ids = [m.user_id for m in members_raw]
        users_map = {}
        if member_user_ids:
            result = await self.session.execute(select(User).where(User.id.in_(member_user_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        member_list = []
        for m in members_raw:
            u = users_map.get(m.user_id)
            if not u:
                continue
            initials = "".join(
                [w[0].upper() for w in u.full_name.split()[:2]]
            ) or "?"
            member_list.append({
                "user_id": m.user_id,
                "name": u.full_name,
                "initials": initials,
                "role": m.role,
                "is_online": manager.is_online(m.user_id),
                "photo_url": u.photo_url,
            })

        # Fetch tasks
        result = await self.session.execute(
            select(Task).where(Task.project_id == project.id)
        )
        tasks = result.scalars().all()
        total_tasks = len(tasks)
        done_tasks = sum(1 for t in tasks if t.status == TASK_DONE)

        # Fetch pending applications
        result = await self.session.execute(
            select(ProjectApplication).where(
                ProjectApplication.project_id == project.id,
                ProjectApplication.status == APP_PENDING,
            )
        )
        pending_apps = result.scalars().all()
        applicant_count = len(pending_apps)

        # Fetch latest message
        result = await self.session.execute(
            select(Message)
            .where(Message.project_id == project.id)
            .order_by(Message.created_at.desc())
            .limit(1)
        )
        last_msg = result.scalar_one_or_none()

        last_task = next(
            (t for t in sorted(tasks, key=lambda x: x.created_at, reverse=True)),
            None,
        )
        last_activity_time = project.created_at
        activity_cue = None

        if last_msg:
            last_activity_time = last_msg.created_at
            result = await self.session.execute(select(User).where(User.id == last_msg.sender_id))
            sender = result.scalar_one_or_none()
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

        member_user_ids = [m.user_id for m in members]
        users_map = {}
        if member_user_ids:
            result = await self.session.execute(select(User).where(User.id.in_(member_user_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        member_list = []
        for m in members:
            u = users_map.get(m.user_id)
            if not u:
                continue
            initials = "".join(
                [w[0].upper() for w in u.full_name.split()[:2]]
            ) or "?"
            member_list.append({
                "user_id": m.user_id,
                "name": u.full_name,
                "initials": initials,
                "role": m.role,
                "is_online": manager.is_online(m.user_id),
                "photo_url": u.photo_url,
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

    async def list_workspaces(self, user_id: str, skip: int = 0, limit: int = 20) -> list[dict]:
        result = await self.session.execute(
            select(Project)
            .where(Project.owner_id == user_id)
            .order_by(Project.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        owned = result.scalars().all()

        result = await self.session.execute(
            select(ProjectMember)
            .where(ProjectMember.user_id == user_id)
            .offset(skip)
            .limit(limit)
        )
        memberships = result.scalars().all()

        project_map = {}
        for p in owned:
            project_map[p.id] = (p, "Pemilik")
        for m in memberships:
            result = await self.session.execute(select(Project).where(Project.id == m.project_id))
            proj = result.scalar_one_or_none()
            if proj and proj.id not in project_map:
                project_map[proj.id] = (proj, m.role)

        project_ids = list(project_map.keys())
        if not project_ids:
            return []

        all_members = await self.session.execute(
            select(ProjectMember).where(ProjectMember.project_id.in_(project_ids))
        )
        all_members = all_members.scalars().all()

        all_tasks = await self.session.execute(
            select(Task).where(Task.project_id.in_(project_ids))
        )
        all_tasks = all_tasks.scalars().all()

        all_apps = await self.session.execute(
            select(ProjectApplication).where(
                ProjectApplication.project_id.in_(project_ids),
                ProjectApplication.status == APP_PENDING,
            )
        )
        all_apps = all_apps.scalars().all()

        all_msgs = await self.session.execute(
            select(Message)
            .where(Message.project_id.in_(project_ids), Message.project_id.isnot(None))
            .order_by(Message.created_at.desc())
        )
        all_msgs = all_msgs.scalars().all()

        all_latest_msgs: dict[int, tuple] = {}
        seen = set()
        for m in all_msgs:
            if m.project_id is not None and m.project_id not in seen:
                seen.add(m.project_id)
                result = await self.session.execute(select(User).where(User.id == m.sender_id))
                sender = result.scalar_one_or_none()
                sender_name = sender.full_name if sender else "Seseorang"
                all_latest_msgs[m.project_id] = (m, sender_name)

        members_by_pid: dict[int, list] = {}
        for m in all_members:
            members_by_pid.setdefault(m.project_id, []).append(m)
        tasks_by_pid: dict[int, list] = {}
        for t in all_tasks:
            tasks_by_pid.setdefault(t.project_id, []).append(t)
        apps_by_pid: dict[int, list] = {}
        for a in all_apps:
            apps_by_pid.setdefault(a.project_id, []).append(a)

        result_data = []
        for pid, (project, role) in project_map.items():
            data = await self._build_workspace_data_fast(
                project, user_id, role,
                members=members_by_pid.get(pid, []),
                tasks=tasks_by_pid.get(pid, []),
                pending_apps=apps_by_pid.get(pid, []),
                latest_msg_info=all_latest_msgs.get(pid),
            )
            result_data.append(data)
        return result_data

    async def get_detail(self, project_id: int, user_id: str) -> dict:
        project, role = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")
        return await self._build_workspace_data(project, user_id, role)

    async def get_discussions(self, project_id: int, user_id: str, limit: int) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        result = await self.session.execute(
            select(Message)
            .where(Message.project_id == project_id)
            .order_by(Message.created_at.desc())
            .limit(limit)
        )
        messages = result.scalars().all()

        sender_ids = [m.sender_id for m in messages]
        users_map = {}
        if sender_ids:
            result = await self.session.execute(select(User).where(User.id.in_(sender_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for m in reversed(messages):
            attachment_data = None
            if m.attachment_url:
                attachment_data = {
                    "url": m.attachment_url,
                    "name": m.attachment_name,
                    "size": m.attachment_size,
                }
            sender = users_map.get(m.sender_id)
            result_data.append({
                "id": m.id,
                "sender": sender.full_name if sender else "System",
                "sender_id": m.sender_id,
                "body": m.content,
                "type": m.type,
                "time": tz_iso(m.created_at),
                "is_me": m.sender_id == user_id,
                "is_system": m.type == "system",
                "reply_to": m.reply_to_id,
                "attachment": attachment_data,
            })
        return result_data

    async def list_files(self, project_id: int, user_id: str, skip: int = 0, limit: int = 50) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        result = await self.session.execute(
            select(ProjectFile)
            .where(ProjectFile.project_id == project_id)
            .order_by(ProjectFile.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        files = result.scalars().all()

        uploader_ids = [f.user_id for f in files]
        users_map = {}
        if uploader_ids:
            result = await self.session.execute(select(User).where(User.id.in_(uploader_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for f in files:
            uploader = users_map.get(f.user_id)
            size_str = f"{f.size / 1024:.0f} KB" if f.size else "Unknown"
            ext = f.name.split(".")[-1] if "." in f.name else "file"
            result_data.append({
                "id": f.id,
                "name": f.name,
                "uploader": uploader.full_name if uploader else "Unknown",
                "date": self._format_relative_time(f.created_at),
                "size": size_str,
                "type": ext,
                "url": f.url,
            })
        return result_data

    async def upload_file(
        self, project_id: int, user_id: str,
        file_content: bytes, filename: str, content_type: str, size: int
    ) -> dict:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        url = await upload_image_to_cloudinary(file_content, folder_name="rembugan_workspace_files")

        pf = ProjectFile(
            project_id=project_id,
            user_id=user_id,
            name=filename or "untitled",
            url=url,
            size=size,
            mime_type=content_type,
        )
        self.session.add(pf)
        await self.session.commit()
        await self.session.refresh(pf)

        # Refresh uploader data
        result = await self.session.execute(select(User).where(User.id == user_id))
        uploader = result.scalar_one_or_none()

        room_id = str(project_id)
        save_msg_coro = self._save_file_message(user_id, project_id, pf)
        fire_and_forget(save_msg_coro, "save_file_message")

        fire_and_forget(
            manager.broadcast({
                "sender_id": user_id,
                "sender_name": uploader.full_name if uploader else "Seseorang",
                "sender_photo_url": uploader.photo_url if uploader else None,
                "text": "",
                "type": "file",
                "attachment_url": pf.url,
                "attachment_name": pf.name,
                "attachment_size": pf.size,
                "timestamp": datetime.now(timezone.utc).isoformat(),
            }, room_id),
            "broadcast_file_upload"
        )

        # Notify other members
        result = await self.session.execute(
            select(ProjectMember).where(ProjectMember.project_id == project_id)
        )
        members = result.scalars().all()
        for m in members:
            if m.user_id != user_id:
                fire_and_forget(
                    notify(self.session, m.user_id, NOTIF_FILE_UPLOADED,
                           f"File baru di {project.title}",
                           f"{uploader.full_name if uploader else 'Seseorang'} mengunggah {pf.name}",
                           f"/workspace/{project_id}"),
                    "notify_file_upload"
                )

        return {
            "id": pf.id,
            "name": pf.name,
            "uploader": uploader.full_name if uploader else "Unknown",
            "size": f"{pf.size / 1024:.0f} KB" if pf.size else "Unknown",
            "type": pf.name.split(".")[-1] if "." in pf.name else "file",
            "url": pf.url,
        }

    async def _save_file_message(self, user_id: str, project_id: int, pf: ProjectFile):
        async with async_session_factory() as s:
            msg = Message(
                content="",
                type="file",
                sender_id=user_id,
                project_id=project_id,
                attachment_name=pf.name,
                attachment_url=pf.url,
                attachment_size=pf.size,
            )
            s.add(msg)
            await s.commit()

    async def delete_file(self, project_id: int, file_id: int, user_id: str) -> str:
        project, role = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        result = await self.session.execute(
            select(ProjectFile).where(
                ProjectFile.id == file_id,
                ProjectFile.project_id == project_id,
            )
        )
        pf = result.scalar_one_or_none()
        if not pf:
            raise HTTPException(status_code=404, detail="File tidak ditemukan")

        if pf.user_id != user_id and project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Tidak bisa menghapus file ini")

        await self.session.delete(pf)
        await self.session.commit()
        return pf.name

    async def list_applicants(self, project_id: int, user_id: str) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya pemilik yang bisa melihat pelamar")

        result = await self.session.execute(
            select(ProjectApplication)
            .where(
                ProjectApplication.project_id == project_id,
                ProjectApplication.status == APP_PENDING,
            )
            .order_by(ProjectApplication.applied_at.desc())
        )
        apps = result.scalars().all()

        applicant_ids = [a.applicant_id for a in apps]
        users_map = {}
        if applicant_ids:
            result = await self.session.execute(select(User).where(User.id.in_(applicant_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for a in apps:
            applicant = users_map.get(a.applicant_id)
            skills = [s.skill.name for s in (applicant.skills or [])] if applicant else []
            result_data.append({
                "id": str(a.id),
                "workspace_id": str(project_id),
                "name": applicant.full_name if applicant else "Unknown",
                "role": ROLE_ANGGOTA,
                "note": "",
                "skills": skills,
                "applied_at": tz_iso(a.applied_at),
            })
        return result_data

    async def get_activities(self, project_id: int, user_id: str, limit: int) -> list[dict]:
        project, _ = await self._get_user_role(project_id, user_id)
        if not project:
            raise HTTPException(status_code=404, detail="Workspace tidak ditemukan")

        activities = []

        result = await self.session.execute(
            select(Message)
            .where(Message.project_id == project_id)
            .order_by(Message.created_at.desc())
            .limit(limit)
        )
        messages = result.scalars().all()
        msg_sender_ids = [m.sender_id for m in messages]
        msg_users_map = {}
        if msg_sender_ids:
            result = await self.session.execute(select(User).where(User.id.in_(msg_sender_ids)))
            msg_users_map = {u.id: u for u in result.scalars().all()}

        for m in messages:
            sender = msg_users_map.get(m.sender_id)
            activities.append({
                "text": f"{sender.full_name if sender else 'Seseorang'} mengirim pesan",
                "time": self._format_relative_time(m.created_at),
                "workspace": project.title,
                "type": "message",
                "created_at": m.created_at.isoformat(),
            })

        result = await self.session.execute(
            select(Task)
            .where(Task.project_id == project_id)
            .order_by(Task.created_at.desc())
            .limit(limit)
        )
        tasks = result.scalars().all()

        task_ids = [t.id for t in tasks]
        assignees_map = {}
        assignee_users_map = {}
        if task_ids:
            result = await self.session.execute(
                select(TaskAssignee).where(TaskAssignee.task_id.in_(task_ids))
            )
            assignees = result.scalars().all()
            user_ids = list(set(a.user_id for a in assignees))
            if user_ids:
                result = await self.session.execute(select(User).where(User.id.in_(user_ids)))
                assignee_users_map = {u.id: u for u in result.scalars().all()}
            for a in assignees:
                assignees_map.setdefault(a.task_id, []).append(a)

        for t in tasks:
            status_text = {
                TASK_TODO: "ditambahkan",
                TASK_DOING: "sedang dikerjakan",
                TASK_DONE: "diselesaikan",
            }
            actions = status_text.get(t.status, "diupdate")
            task_assignees = assignees_map.get(t.id, [])
            names = [assignee_users_map.get(a.user_id).full_name if assignee_users_map.get(a.user_id) else "Seseorang" for a in task_assignees]
            assignee_str = ", ".join(names) if names else "Seseorang"
            activities.append({
                "text": f"Task '{t.title}' {actions} oleh {assignee_str}",
                "time": self._format_relative_time(t.created_at),
                "workspace": project.title,
                "type": "task",
                "created_at": t.created_at.isoformat(),
            })

        result = await self.session.execute(
            select(ProjectFile)
            .where(ProjectFile.project_id == project_id)
            .order_by(ProjectFile.created_at.desc())
            .limit(limit)
        )
        files = result.scalars().all()
        file_uploader_ids = [f.user_id for f in files]
        file_users_map = {}
        if file_uploader_ids:
            result = await self.session.execute(select(User).where(User.id.in_(file_uploader_ids)))
            file_users_map = {u.id: u for u in result.scalars().all()}

        for f in files:
            uploader = file_users_map.get(f.user_id)
            activities.append({
                "text": f"{uploader.full_name if uploader else 'Seseorang'} mengupload {f.name}",
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
        title: str, assignee_ids: list[str], deadline: str | None,
        description: str | None = None,
    ) -> dict:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == project_id,
                ProjectMember.user_id == user_id,
            )
        )
        member = result.scalar_one_or_none()
        if not member and project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

        deadline_dt = _parse_dt(deadline) if deadline else None

        valid_assignee_ids = []
        if assignee_ids:
            result = await self.session.execute(select(User).where(User.id.in_(assignee_ids)))
            existing_users = result.scalars().all()
            valid_ids = {u.id for u in existing_users}
            for uid in assignee_ids:
                if uid in valid_ids:
                    valid_assignee_ids.append(uid)

        task = Task(
            project_id=project_id,
            title=title,
            description=description,
            status=TASK_TODO,
            deadline=deadline_dt,
        )
        self.session.add(task)
        await self.session.flush()

        for uid in valid_assignee_ids:
            self.session.add(TaskAssignee(task_id=task.id, user_id=uid))
        await self.session.commit()
        await self.session.refresh(task)

        # Notify assignees
        for uid in valid_assignee_ids:
            if uid != user_id:
                await notify(
                    self.session,
                    user_id=uid,
                    type_=NOTIF_TASK_ASSIGNED,
                    title="Tugas Baru",
                    content=f"Kamu ditugaskan: {task.title}",
                    link=f"/workspace/{project_id}",
                )

        result = await self.session.execute(
            select(TaskAssignee).where(TaskAssignee.task_id == task.id)
        )
        task_assignees = result.scalars().all()
        assignee_user_ids = [a.user_id for a in task_assignees]
        a_users_map = {}
        if assignee_user_ids:
            result = await self.session.execute(select(User).where(User.id.in_(assignee_user_ids)))
            a_users_map = {u.id: u for u in result.scalars().all()}

        return {
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "status": task.status,
            "assignees": [
                {"id": a.user_id, "name": a_users_map.get(a.user_id).full_name if a_users_map.get(a.user_id) else None}
                for a in task_assignees
            ],
            "deadline": task.deadline.isoformat() if task.deadline else None,
            "created_at": tz_iso(task.created_at),
        }

    async def move_task(self, task_id: int, status: str, user_id: str) -> dict:
        result = await self.session.execute(
            select(Task).where(Task.id == task_id)
        )
        task = result.scalar_one_or_none()
        if not task:
            raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == task.project_id,
                ProjectMember.user_id == user_id,
            )
        )
        is_member = result.scalar_one_or_none()
        if not is_member:
            raise HTTPException(status_code=403, detail="Akses ditolak. Anda bukan anggota proyek ini.")

        task.status = status
        await self.session.commit()

        return {
            "id": task.id,
            "title": task.title,
            "status": task.status,
        }

    async def get_tasks(self, project_id: int, user_id: str, skip: int = 0, limit: int = 50) -> dict:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        result = await self.session.execute(
            select(Task)
            .where(Task.project_id == project_id)
            .order_by(Task.created_at.asc())
            .offset(skip)
            .limit(limit)
        )
        tasks = result.scalars().all()

        task_ids = [t.id for t in tasks]
        assignees_map = {}
        a_users_map = {}
        if task_ids:
            result = await self.session.execute(
                select(TaskAssignee).where(TaskAssignee.task_id.in_(task_ids))
            )
            assignees = result.scalars().all()
            user_ids = list(set(a.user_id for a in assignees))
            if user_ids:
                result = await self.session.execute(select(User).where(User.id.in_(user_ids)))
                a_users_map = {u.id: u for u in result.scalars().all()}
            for a in assignees:
                assignees_map.setdefault(a.task_id, []).append(a)

        board = {TASK_TODO: [], TASK_DOING: [], TASK_DONE: []}
        for t in tasks:
            task_assignees = assignees_map.get(t.id, [])
            item = {
                "id": t.id,
                "title": t.title,
                "description": t.description,
                "status": t.status,
                "assignees": [
                    {"id": a.user_id, "name": a_users_map.get(a.user_id).full_name if a_users_map.get(a.user_id) else None}
                    for a in task_assignees
                ],
                "deadline": t.deadline.isoformat() if t.deadline else None,
                "created_at": tz_iso(t.created_at),
            }
            if t.status in board:
                board[t.status].append(item)

        return {"project_id": project_id, "board": board}

    async def update_task(
        self, task_id: int, user_id: str,
        title: str | None, deadline: str | None, assignee_ids: list[str] | None,
        description: str | None = None,
    ) -> dict:
        result = await self.session.execute(
            select(Task).where(Task.id == task_id)
        )
        task = result.scalar_one_or_none()
        if not task:
            raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == task.project_id,
                ProjectMember.user_id == user_id,
            )
        )
        member = result.scalar_one_or_none()
        if not member and task.project_id:
            result = await self.session.execute(select(Project).where(Project.id == task.project_id))
            proj_check = result.scalar_one_or_none()
            if not proj_check or proj_check.owner_id != user_id:
                raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

        if title is not None:
            task.title = title
        if description is not None:
            task.description = description
        if deadline is not None:
            task.deadline = _parse_dt(deadline)

        if assignee_ids is not None:
            await self.session.execute(
                delete(TaskAssignee).where(TaskAssignee.task_id == task_id)
            )
            for uid in assignee_ids:
                self.session.add(TaskAssignee(task_id=task_id, user_id=uid))
            for uid in assignee_ids:
                if uid != user_id:
                    await notify(
                        self.session,
                        user_id=uid,
                        type_=NOTIF_TASK_ASSIGNED,
                        title="Tugas Diperbarui",
                        content=f"Kamu ditugaskan: {task.title}",
                        link=f"/workspace/{task.project_id}",
                    )

        await self.session.commit()

        result = await self.session.execute(
            select(TaskAssignee).where(TaskAssignee.task_id == task_id)
        )
        task_assignees = result.scalars().all()
        assignee_user_ids = [a.user_id for a in task_assignees]
        a_users_map = {}
        if assignee_user_ids:
            result = await self.session.execute(select(User).where(User.id.in_(assignee_user_ids)))
            a_users_map = {u.id: u for u in result.scalars().all()}

        return {
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "status": task.status,
            "assignees": [
                {"id": a.user_id, "name": a_users_map.get(a.user_id).full_name if a_users_map.get(a.user_id) else None}
                for a in task_assignees
            ],
            "deadline": task.deadline.isoformat() if task.deadline else None,
        }

    async def delete_task(self, task_id: int, user_id: str) -> str:
        result = await self.session.execute(
            select(Task).where(Task.id == task_id)
        )
        task = result.scalar_one_or_none()
        if not task:
            raise HTTPException(status_code=404, detail="Tugas tidak ditemukan.")

        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == task.project_id,
                ProjectMember.user_id == user_id,
            )
        )
        member = result.scalar_one_or_none()
        if not member:
            result = await self.session.execute(select(Project).where(Project.id == task.project_id))
            proj_check = result.scalar_one_or_none()
            if not proj_check or proj_check.owner_id != user_id:
                raise HTTPException(status_code=403, detail="Kamu bukan member proyek ini.")

        title = task.title
        await self.session.delete(task)
        await self.session.commit()
        return title

    async def kick_member(self, project_id: int, target_user_id: str, requester_id: str) -> None:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        if project.owner_id != requester_id:
            raise HTTPException(status_code=403, detail="Hanya ketua proyek yang bisa mengeluarkan anggota.")

        if target_user_id == requester_id:
            raise HTTPException(status_code=400, detail="Tidak bisa mengeluarkan diri sendiri.")

        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == project_id,
                ProjectMember.user_id == target_user_id,
            )
        )
        member = result.scalar_one_or_none()
        if not member:
            raise HTTPException(status_code=404, detail="Anggota tidak ditemukan.")

        await self.session.delete(member)
        await self.session.commit()

    async def end_collaboration(self, project_id: int, user_id: str) -> str:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya ketua proyek yang bisa mengakhiri kolaborasi.")

        project.status = PJ_COMPLETED
        await self.session.commit()
        return project.title
