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


class ApplicationResponse(BaseModel):
    """Response data lamaran."""
    id: int
    project_id: int
    applicant_id: str
    status: str
    applied_at: datetime
    applicant_name: Optional[str] = None
    project_title: Optional[str] = None
