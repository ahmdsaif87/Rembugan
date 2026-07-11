from dataclasses import dataclass
from fastapi import Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import (
    PJ_OPEN, PJ_ONGOING, APP_PENDING, APP_ACCEPTED, APP_REJECTED, ROLE_ANGGOTA,
    NOTIF_APPLICATION_RECEIVED, NOTIF_APPLICATION_ACCEPTED, NOTIF_APPLICATION_REJECTED,
)
from app.models import User, Project, ProjectMember, ProjectApplication
from app.services.base import BaseService
from app.services.notification import notify


@dataclass
class CollaborationService(BaseService):
    session: AsyncSession = Depends(get_db_session)

    async def apply(self, project_id: int, user_id: str, message: str | None = None, contact_info: str | None = None):
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
        if project.status != PJ_OPEN:
            raise HTTPException(status_code=400, detail="Proyek ini sudah tidak menerima lamaran.")
        if project.owner_id == user_id:
            raise HTTPException(status_code=400, detail="Tidak bisa melamar ke proyek sendiri.")

        result = await self.session.execute(
            select(ProjectApplication).where(
                ProjectApplication.project_id == project_id,
                ProjectApplication.applicant_id == user_id,
            )
        )
        existing = result.scalar_one_or_none()
        if existing:
            raise HTTPException(status_code=400, detail="Kamu sudah melamar ke proyek ini.")

        application = ProjectApplication(project_id=project_id, applicant_id=user_id)
        self.session.add(application)
        await self.session.commit()
        await self.session.refresh(application)

        # Fetch owner
        result = await self.session.execute(select(User).where(User.id == project.owner_id))
        owner = result.scalar_one_or_none()

        result = await self.session.execute(select(User).where(User.id == user_id))
        applicant_user = result.scalar_one_or_none()

        await notify(
            self.session, project.owner_id, NOTIF_APPLICATION_RECEIVED,
            "Lamaran Baru",
            f"{applicant_user.full_name if applicant_user else 'Seseorang'} ingin bergabung ke '{project.title}'",
            link=f"/workspace/{project.id}",
        )

        return {
            "id": application.id,
            "project_title": project.title,
            "applicant_name": applicant_user.full_name if applicant_user else None,
            "status": application.status,
            "applied_at": application.applied_at.isoformat(),
        }

    async def list_applications(self, project_id: int, user_id: str):
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya owner proyek yang bisa melihat lamaran.")

        result = await self.session.execute(
            select(ProjectApplication)
            .where(ProjectApplication.project_id == project_id)
            .order_by(ProjectApplication.applied_at.desc())
        )
        applications = result.scalars().all()

        applicant_ids = [a.applicant_id for a in applications]
        users_map = {}
        if applicant_ids:
            result = await self.session.execute(select(User).where(User.id.in_(applicant_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for app in applications:
            applicant = users_map.get(app.applicant_id)
            skills = []
            if applicant and applicant.skills:
                skills = [us.skill.name for us in applicant.skills]
            result_data.append({
                "id": app.id,
                "applicant_id": app.applicant_id,
                "applicant_name": applicant.full_name if applicant else None,
                "applicant_skills": skills,
                "status": app.status,
                "applied_at": app.applied_at.isoformat(),
            })

        return result_data

    async def respond_to_application(self, application_id: int, user_id: str, status: str, role: str = ROLE_ANGGOTA):
        result = await self.session.execute(
            select(ProjectApplication).where(ProjectApplication.id == application_id)
        )
        application = result.scalar_one_or_none()
        if not application:
            raise HTTPException(status_code=404, detail="Lamaran tidak ditemukan.")

        result = await self.session.execute(select(Project).where(Project.id == application.project_id))
        project = result.scalar_one_or_none()

        if not project or project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya owner proyek yang bisa merespons lamaran.")

        if application.status != APP_PENDING:
            raise HTTPException(status_code=400, detail=f"Lamaran sudah di-{application.status}.")

        application.status = status
        await self.session.commit()

        if status == APP_ACCEPTED:
            await notify(
                self.session, application.applicant_id, NOTIF_APPLICATION_ACCEPTED,
                "Lamaran Diterima",
                f"Selamat! Kamu diterima di proyek '{project.title}'",
            )
        else:
            await notify(
                self.session, application.applicant_id, NOTIF_APPLICATION_REJECTED,
                "Lamaran Ditolak",
                f"Maaf, lamaranmu di proyek '{project.title}' ditolak.",
            )

        if status == APP_ACCEPTED:
            ts = project.total_slots
            current = 0
            if ts is not None:
                result = await self.session.execute(
                    select(func.count(ProjectMember.id)).where(
                        ProjectMember.project_id == application.project_id
                    )
                )
                current = result.scalar() or 0
                if current >= ts:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Slot proyek sudah penuh ({current}/{ts})",
                    )
            member = ProjectMember(
                project_id=application.project_id,
                user_id=application.applicant_id,
                role=role,
            )
            self.session.add(member)
            await self.session.commit()
            if ts is not None and current + 1 >= ts:
                project.status = PJ_ONGOING
                await self.session.commit()

        return {
            "application_id": application.id,
            "new_status": application.status,
        }
