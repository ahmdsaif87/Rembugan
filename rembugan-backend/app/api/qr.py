import os
from datetime import datetime, timezone, timedelta
import secrets
from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma

from app.core.database import get_db
from app.core.security import verify_token
from app.core.constants import ROLE_ADMIN, ROLE_ANGGOTA

APP_URL = os.getenv("APP_URL", "https://rembugan.app")

router = APIRouter(prefix="/qr", tags=["8. QR Code"])


@router.get("/profile")
async def get_profile_qr(
    user_token: dict = Depends(verify_token),
):
    """Return QR payload for current user's profile."""
    uid = user_token.get("uid")
    return {
        "status": "success",
        "data": {
            "qr_data": f"{APP_URL}/u/{uid}",
            "type": "profile",
            "user_id": uid,
        }
    }


@router.get("/profile/{user_id}")
async def get_other_profile_qr(
    user_id: str,
    db: Prisma = Depends(get_db),
):
    """Return QR payload for another user's profile."""
    user = await db.user.find_unique(where={"id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
    return {
        "status": "success",
        "data": {
            "qr_data": f"{APP_URL}/u/{user_id}",
            "type": "profile",
            "user_id": user_id,
        }
    }


@router.get("/showcase/{showcase_id}", summary="QR Link Showcase")
async def get_showcase_qr(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Return QR payload for a showcase."""
    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
    return {
        "status": "success",
        "data": {
            "qr_data": f"{APP_URL}/s/{showcase_id}",
            "type": "showcase",
            "showcase_id": showcase_id,
        }
    }


@router.post("/project/{project_id}/invite")
async def create_project_invite(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Generate invite token and QR payload for a project."""
    uid = user_token.get("uid")

    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Project tidak ditemukan")
    is_admin = user_token.get("role") == ROLE_ADMIN
    if not is_admin and project.owner_id != uid:
        raise HTTPException(status_code=403, detail="Hanya owner project yang bisa membuat invite")

    token = secrets.token_urlsafe(32)

    invite = await db.projectinvite.create(
        data={
            "project_id": project_id,
            "token": token,
            "created_by": uid,
            "expires_at": datetime.now(timezone.utc) + timedelta(days=7),
        }
    )

    return {
        "status": "success",
        "data": {
            "token": invite.token,
            "qr_data": f"{APP_URL}/join/{invite.token}",
            "type": "project_invite",
            "project_id": project_id,
            "expires_at": invite.expires_at.isoformat(),
        }
    }


@router.get("/project/join/{token}")
async def verify_invite_token(
    token: str,
    db: Prisma = Depends(get_db),
):
    """Verify if a project invite token is valid."""
    invite = await db.projectinvite.find_unique(where={"token": token})
    if not invite:
        raise HTTPException(status_code=404, detail="Token invite tidak valid")
    if not invite.is_active:
        raise HTTPException(status_code=400, detail="Invite sudah dicabut")

    if invite.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Invite sudah kadaluarsa")

    project = await db.project.find_unique(where={"id": invite.project_id})

    return {
        "status": "success",
        "data": {
            "valid": True,
            "project_id": invite.project_id,
            "project_title": project.title if project else None,
        }
    }


@router.post("/project/join/{token}")
async def join_project_via_invite(
    token: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Join a project using an invite token."""
    uid = user_token.get("uid")

    invite = await db.projectinvite.find_unique(where={"token": token})
    if not invite:
        raise HTTPException(status_code=404, detail="Token invite tidak valid")
    if not invite.is_active:
        raise HTTPException(status_code=400, detail="Invite sudah dicabut")

    if invite.expires_at < datetime.now(timezone.utc):
        raise HTTPException(status_code=400, detail="Invite sudah kadaluarsa")

    existing = await db.projectmember.find_first(
        where={"project_id": invite.project_id, "user_id": uid}
    )
    if existing:
        raise HTTPException(status_code=400, detail="Kamu sudah menjadi member project ini")

    member = await db.projectmember.create(
        data={
            "project_id": invite.project_id,
            "user_id": uid,
                "role": ROLE_ANGGOTA,
        }
    )

    return {
        "status": "success",
        "message": "Berhasil join project!",
        "data": {
            "project_id": invite.project_id,
            "role": member.role,
        }
    }
