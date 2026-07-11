import os
from datetime import datetime, timezone, timedelta
import secrets
from fastapi import Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import ROLE_ADMIN, ROLE_ANGGOTA, PJ_ONGOING
from app.models import User, Project, ProjectMember
from app.models.collaboration import ProjectInvite
from app.models.social import Showcase

APP_URL = os.getenv("APP_URL", "https://rembugan.app")


class QrService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    def get_profile_qr(self, uid: str) -> dict:
        return {
            "qr_data": f"{APP_URL}/u/{uid}",
            "type": "profile",
            "user_id": uid,
        }

    async def get_other_profile_qr(self, user_id: str) -> dict:
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")
        return {
            "qr_data": f"{APP_URL}/u/{user_id}",
            "type": "profile",
            "user_id": user_id,
        }

    async def get_showcase_qr(self, showcase_id: str) -> dict:
        result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
        showcase = result.scalar_one_or_none()
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        return {
            "qr_data": f"{APP_URL}/s/{showcase_id}",
            "type": "showcase",
            "showcase_id": showcase_id,
        }

    async def create_project_invite(self, project_id: int, uid: str, role: str | None) -> dict:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Project tidak ditemukan")
        is_admin = role == ROLE_ADMIN
        if not is_admin and project.owner_id != uid:
            raise HTTPException(status_code=403, detail="Hanya owner project yang bisa membuat invite")

        token = secrets.token_urlsafe(32)

        invite = ProjectInvite(
            project_id=project_id,
            token=token,
            created_by=uid,
            expires_at=datetime.now(timezone.utc) + timedelta(days=7),
        )
        self.session.add(invite)
        await self.session.commit()
        await self.session.refresh(invite)

        return {
            "token": invite.token,
            "qr_data": f"{APP_URL}/join/{invite.token}",
            "type": "project_invite",
            "project_id": project_id,
            "expires_at": invite.expires_at.isoformat(),
        }

    async def verify_invite_token(self, token: str) -> dict:
        result = await self.session.execute(
            select(ProjectInvite).where(ProjectInvite.token == token)
        )
        invite = result.scalar_one_or_none()
        if not invite:
            raise HTTPException(status_code=404, detail="Token invite tidak valid")
        if not invite.is_active:
            raise HTTPException(status_code=400, detail="Invite sudah dicabut")

        if invite.expires_at < datetime.now(timezone.utc):
            raise HTTPException(status_code=400, detail="Invite sudah kadaluarsa")

        result = await self.session.execute(select(Project).where(Project.id == invite.project_id))
        project = result.scalar_one_or_none()

        return {
            "valid": True,
            "project_id": invite.project_id,
            "project_title": project.title if project else None,
        }

    async def join_project_via_invite(self, token: str, uid: str) -> dict:
        result = await self.session.execute(
            select(ProjectInvite).where(ProjectInvite.token == token)
        )
        invite = result.scalar_one_or_none()
        if not invite:
            raise HTTPException(status_code=404, detail="Token invite tidak valid")
        if not invite.is_active:
            raise HTTPException(status_code=400, detail="Invite sudah dicabut")

        if invite.expires_at < datetime.now(timezone.utc):
            raise HTTPException(status_code=400, detail="Invite sudah kadaluarsa")

        result = await self.session.execute(
            select(ProjectMember).where(
                ProjectMember.project_id == invite.project_id,
                ProjectMember.user_id == uid,
            )
        )
        existing = result.scalar_one_or_none()
        if existing:
            raise HTTPException(status_code=400, detail="Kamu sudah menjadi member project ini")

        member = ProjectMember(
            project_id=invite.project_id,
            user_id=uid,
            role=ROLE_ANGGOTA,
        )
        self.session.add(member)
        await self.session.commit()

        result = await self.session.execute(
            select(func.count(ProjectMember.id)).where(
                ProjectMember.project_id == invite.project_id
            )
        )
        current_members = result.scalar() or 0

        result = await self.session.execute(select(Project).where(Project.id == invite.project_id))
        project = result.scalar_one_or_none()
        if project and project.total_slots is not None and current_members >= project.total_slots:
            project.status = PJ_ONGOING
            await self.session.commit()

        return {
            "project_id": invite.project_id,
            "role": member.role,
        }
