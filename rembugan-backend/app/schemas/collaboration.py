from pydantic import BaseModel, Field
from datetime import datetime, timezone, UTC
from typing import Optional


class ApplyInput(BaseModel):
    """Data untuk melamar/request join ke proyek."""
    project_id: int = Field(..., description="ID proyek yang dilamar")


class ApplicationRespondInput(BaseModel):
    """Data untuk merespons lamaran (accept/reject)."""
    status: str = Field(..., pattern="^(accepted|rejected)$", description="Status: accepted atau rejected")
    role: str = Field(default="Anggota", description="Role jika diterima: Ketua, Anggota, Pembimbing")
