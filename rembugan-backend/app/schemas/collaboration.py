from pydantic import BaseModel, Field
from typing import Optional


class ApplyInput(BaseModel):
    """Data untuk melamar/request join ke proyek."""
    message: Optional[str] = None
    contact_info: Optional[str] = None


class RespondInput(BaseModel):
    """Data untuk merespons lamaran (accept/reject)."""
    status: str = Field(..., pattern="^(accepted|rejected)$", description="Status: accepted atau rejected")
    role: str = Field(default="Anggota", description="Role jika diterima: Anggota")
