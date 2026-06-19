from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from pydantic import BaseModel, Field
from typing import Optional, List
from zoneinfo import ZoneInfo
from app.core.dates import tz_iso
from datetime import datetime

from app.core.database import get_db
from app.core.security import verify_token
from app.core.constants import ROLE_KETUA

router = APIRouter(prefix="/posts", tags=["Posts & Offers"])


class CreatePostInput(BaseModel):
    type: str = Field(..., pattern="^(post|offer)$", description="'post' untuk postingan, 'offer' untuk tawaran proyek")

    # Untuk type='post'
    content: Optional[str] = Field(None, min_length=1, description="Isi postingan")
    media_urls: Optional[List[str]] = Field(None, description="URL media (gambar)")
    tags: Optional[List[str]] = Field(None, description="Tag postingan")

    # Untuk type='offer'
    title: Optional[str] = Field(None, min_length=5, max_length=100, description="Nama proyek")
    description: Optional[str] = Field(None, min_length=20, description="Deskripsi proyek")
    required_skills: Optional[List[str]] = Field(None, min_length=1, description="Skill yang dibutuhkan")
    category: Optional[str] = Field(None, description="Kategori proyek")
    interest: Optional[str] = Field(None, description="Minat terkait proyek")
    total_slots: Optional[int] = Field(None, ge=1, description="Slot anggota tersisa")
    deadline: Optional[datetime] = Field(None, description="Batas waktu pendaftaran")


@router.post("/create", summary="Buat Postingan atau Tawaran")
async def create_post(
    data: CreatePostInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Buat postingan (showcase) atau tawaran (project) dalam satu endpoint."""
    uid = user_token.get("uid")

    if data.type == "post":
        if not data.content:
            raise HTTPException(status_code=400, detail="Content wajib diisi untuk postingan")

        showcase = await db.showcase.create(
            data={
                "author_id": uid,
                "content": data.content,
                "media_urls": data.media_urls or [],
                "tags": data.tags or [],
            },
            include={"author": True},
        )

        return {
            "status": "success",
            "message": "Postingan berhasil dibuat!",
            "data": {
                "type": "post",
                "id": showcase.id,
                "content": showcase.content,
                "media_urls": showcase.media_urls,
                "tags": showcase.tags,
                "author_name": showcase.author.full_name,
                "created_at": tz_iso(showcase.created_at),
            },
        }

    elif data.type == "offer":
        if not data.title or not data.description or not data.required_skills:
            raise HTTPException(
                status_code=400,
                detail="title, description, dan required_skills wajib diisi untuk tawaran",
            )

        project = await db.project.create(
            data={
                "owner_id": uid,
                "title": data.title,
                "description": data.description,
                "required_skills": data.required_skills,
                "category": data.category,
                "interest": data.interest,
                "deadline": data.deadline,
                "total_slots": data.total_slots,
            },
            include={"owner": True},
        )

        await db.projectmember.create(
            data={
                "project_id": project.id,
                "user_id": uid,
                    "role": ROLE_KETUA,
            }
        )

        return {
            "status": "success",
            "message": f"Tawaran '{project.title}' berhasil dibuat!",
            "data": {
                "type": "offer",
                "id": project.id,
                "title": project.title,
                "description": project.description,
                "category": project.category,
                "interest": project.interest,
                "required_skills": project.required_skills,
                "total_slots": project.total_slots,
                "deadline": project.deadline.isoformat() if project.deadline else None,
                "owner_name": project.owner.full_name,
                "created_at": tz_iso(project.created_at),
            },
        }
