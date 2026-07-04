from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, timezone, UTC


class ProjectCreateInput(BaseModel):
    """Data untuk membuat proyek baru."""
    title: str = Field(..., min_length=5, max_length=100, description="Judul proyek")
    description: str = Field(..., min_length=20, description="Deskripsi lengkap proyek")
    required_skills: List[str] = Field(..., min_length=1, description="Skill yang dibutuhkan")
    interest: Optional[str] = Field(None, description="Minat terkait proyek")
    category: Optional[str] = Field(None, description="Kategori proyek (Tech, Design, Business, dll)")
    deadline: Optional[datetime] = Field(None, description="Batas waktu pendaftaran")
    total_slots: Optional[int] = Field(None, ge=1, description="Total slot anggota dibutuhkan")
