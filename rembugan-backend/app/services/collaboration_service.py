from dataclasses import dataclass
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import (
    PJ_OPEN, PJ_ONGOING, APP_PENDING, APP_ACCEPTED, APP_REJECTED, ROLE_ANGGOTA,
    NOTIF_APPLICATION_RECEIVED, NOTIF_APPLICATION_ACCEPTED, NOTIF_APPLICATION_REJECTED,
)
from app.services.base import BaseService
from app.services.notification import notify


@dataclass
class CollaborationService(BaseService):
    db: Prisma = Depends(get_db)

    async def apply(self, project_id: int, user_id: str, message: str | None = None, contact_info: str | None = None):
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
        if project.status != PJ_OPEN:
            raise HTTPException(status_code=400, detail="Proyek ini sudah tidak menerima lamaran.")
        if project.owner_id == user_id:
            raise HTTPException(status_code=400, detail="Tidak bisa melamar ke proyek sendiri.")

        existing = await self.db.projectapplication.find_first(
            where={"project_id": project_id, "applicant_id": user_id}
        )
        if existing:
            raise HTTPException(status_code=400, detail="Kamu sudah melamar ke proyek ini.")

        application = await self.db.projectapplication.create(
            data={"project_id": project_id, "applicant_id": user_id},
            include={"project": True, "applicant": True},
        )

        await notify(
            self.db, project.owner_id, NOTIF_APPLICATION_RECEIVED,
            "Lamaran Baru",
            f"{application.applicant.full_name if application.applicant else 'Seseorang'} ingin bergabung ke '{project.title}'",
            link=f"/workspace/{project.id}",
        )

        return {
            "id": application.id,
            "project_title": application.project.title if application.project else None,
            "applicant_name": application.applicant.full_name if application.applicant else None,
            "status": application.status,
            "applied_at": application.applied_at.isoformat(),
        }

    async def list_applications(self, project_id: int, user_id: str):
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya owner proyek yang bisa melihat lamaran.")

        applications = await self.db.projectapplication.find_many(
            where={"project_id": project_id},
            include={"applicant": {"include": {"skills": {"include": {"skill": True}}}}},
            order={"applied_at": "desc"},
        )

        result = []
        for app in applications:
            skills = []
            if app.applicant and app.applicant.skills:
                skills = [us.skill.name for us in app.applicant.skills]
            result.append({
                "id": app.id,
                "applicant_id": app.applicant_id,
                "applicant_name": app.applicant.full_name if app.applicant else None,
                "applicant_skills": skills,
                "status": app.status,
                "applied_at": app.applied_at.isoformat(),
            })

        return result

    async def respond_to_application(self, application_id: int, user_id: str, status: str, role: str = ROLE_ANGGOTA):
        application = await self.db.projectapplication.find_unique(
            where={"id": application_id},
            include={"project": True},
        )
        if not application:
            raise HTTPException(status_code=404, detail="Lamaran tidak ditemukan.")

        if application.project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Hanya owner proyek yang bisa merespons lamaran.")

        if application.status != APP_PENDING:
            raise HTTPException(status_code=400, detail=f"Lamaran sudah di-{application.status}.")

        updated = await self.db.projectapplication.update(
            where={"id": application_id},
            data={"status": status},
            include={"project": True},
        )

        if status == APP_ACCEPTED:
            await notify(
                self.db, application.applicant_id, NOTIF_APPLICATION_ACCEPTED,
                "Lamaran Diterima",
                f"Selamat! Kamu diterima di proyek '{application.project.title}'",
            )
        else:
            await notify(
                self.db, application.applicant_id, NOTIF_APPLICATION_REJECTED,
                "Lamaran Ditolak",
                f"Maaf, lamaranmu di proyek '{application.project.title}' ditolak.",
            )

        if status == APP_ACCEPTED:
            ts = application.project.total_slots
            current = 0
            if ts is not None:
                current = await self.db.projectmember.count(
                    where={"project_id": application.project_id}
                )
                if current >= ts:
                    raise HTTPException(
                        status_code=400,
                        detail=f"Slot proyek sudah penuh ({current}/{ts})",
                    )
            await self.db.projectmember.create(
                data={
                    "project_id": application.project_id,
                    "user_id": application.applicant_id,
                    "role": role,
                }
            )
            if ts is not None and current + 1 >= ts:
                await self.db.project.update(
                    where={"id": application.project_id},
                    data={"status": PJ_ONGOING},
                )

        return {
            "application_id": updated.id,
            "new_status": updated.status,
        }
