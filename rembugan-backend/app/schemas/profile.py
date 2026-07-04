from typing import Optional, List
from pydantic import BaseModel, Field
from app.schemas.user import ExperienceInput


class SettingsUpdateInput(BaseModel):
    full_name: Optional[str] = Field(None, description="Nama lengkap")
    handle: Optional[str] = Field(None, description="@username")
    bio: Optional[str] = Field(None, description="Bio singkat")
    interest: Optional[str] = Field(None, description="Minat/bidang")
    photo_url: Optional[str] = Field(None, description="URL foto profil")
    cover_url: Optional[str] = Field(None, description="URL cover profile")
    social_links: Optional[dict] = Field(None, description="Link sosial media (instagram, linkedin, website)")
    skills: Optional[List[str]] = Field(None, description="Daftar skill/keahlian")
    experiences: Optional[List[ExperienceInput]] = Field(None, description="Riwayat pengalaman")
