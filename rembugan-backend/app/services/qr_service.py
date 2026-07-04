import os
from datetime import datetime, timezone, timedelta
import secrets
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import ROLE_ADMIN, ROLE_ANGGOTA, PJ_ONGOING

APP_URL = os.getenv("APP_URL", "https://rembugan.app")


class QrService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    def get_profile_qr(self, uid: str) -> dict:
        return {
            "qr_data": f"{APP_URL}/u/{uid}",
            "type": "profile",
            "user_id": uid,
        }

    async def get_other_profile_qr(self, user_id: str) -> dict:
        user = await self.db.user.find_unique(where={"id": user_id})
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")
        return {
            "qr_data": f"{APP_URL}/u/{user_id}",
            "type": "profile",
            "user_id": user_id,
        }

    async def get_showcase_qr(self, showcase_id: str) -> dict:
        showcase = await self.db.showcase.find_unique(where={"id": showcase_id})
        if not showcase:
            raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        return {
            "qr_data": f"{APP_URL}/s/{showcase_id}",
            "type": "showcase",
            "showcase_id": showcase_id,
        }

    async def create_project_invite(self, project_id: int, uid: str, role: str | None) -> dict:
        project = await self.db.project.find_unique(where={"id": project_id})
        if not project:
            raise HTTPException(status_code=404, detail="Project tidak ditemukan")
        is_admin = role == ROLE_ADMIN
        if not is_admin and project.owner_id != uid:
            raise HTTPException(status_code=403, detail="Hanya owner project yang bisa membuat invite")

        token = secrets.token_urlsafe(32)

        invite = await self.db.projectinvite.create(
            data={
                "project_id": project_id,
                "token": token,
                "created_by": uid,
                "expires_at": datetime.now(timezone.utc) + timedelta(days=7),
            }
        )

        return {
            "token": invite.token,
            "qr_data": f"{APP_URL}/join/{invite.token}",
            "type": "project_invite",
            "project_id": project_id,
            "expires_at": invite.expires_at.isoformat(),
        }

    async def verify_invite_token(self, token: str) -> dict:
        invite = await self.db.projectinvite.find_unique(where={"token": token})
        if not invite:
            raise HTTPException(status_code=404, detail="Token invite tidak valid")
        if not invite.is_active:
            raise HTTPException(status_code=400, detail="Invite sudah dicabut")

        if invite.expires_at < datetime.now(timezone.utc):
            raise HTTPException(status_code=400, detail="Invite sudah kadaluarsa")

        project = await self.db.project.find_unique(where={"id": invite.project_id})

        return {
            "valid": True,
            "project_id": invite.project_id,
            "project_title": project.title if project else None,
        }

    async def join_project_via_invite(self, token: str, uid: str) -> dict:
        invite = await self.db.projectinvite.find_unique(where={"token": token})
        if not invite:
            raise HTTPException(status_code=404, detail="Token invite tidak valid")
        if not invite.is_active:
            raise HTTPException(status_code=400, detail="Invite sudah dicabut")

        if invite.expires_at < datetime.now(timezone.utc):
            raise HTTPException(status_code=400, detail="Invite sudah kadaluarsa")

        existing = await self.db.projectmember.find_first(
            where={"project_id": invite.project_id, "user_id": uid}
        )
        if existing:
            raise HTTPException(status_code=400, detail="Kamu sudah menjadi member project ini")

        member = await self.db.projectmember.create(
            data={
                "project_id": invite.project_id,
                "user_id": uid,
                "role": ROLE_ANGGOTA,
            }
        )

        current_members = await self.db.projectmember.count(
            where={"project_id": invite.project_id}
        )
        project = await self.db.project.find_unique(
            where={"id": invite.project_id}
        )
        if project and project.total_slots is not None and current_members >= project.total_slots:
            await self.db.project.update(
                where={"id": invite.project_id},
                data={"status": PJ_ONGOING},
            )

        return {
            "project_id": invite.project_id,
            "role": member.role,
        }
