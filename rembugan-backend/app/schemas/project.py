from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, timezone, UTC


class ProjectCreateInput(BaseModel):
    """Data untuk membuat proyek baru."""
    title: str = Field(..., min_length=5, max_length=100, description="Judul proyek")
    description: str = Field(..., min_length=20, description="Deskripsi lengkap proyek")
    required_skills: List[str] = Field(..., min_length=1, description="Skill yang dibutuhkan")


class ProjectResponse(BaseModel):
    """Response data proyek."""
    id: int
    owner_id: str
    title: str
    description: str
    required_skills: List[str]
    status: str
    created_at: datetime
    owner_name: Optional[str] = None
    member_count: Optional[int] = None
