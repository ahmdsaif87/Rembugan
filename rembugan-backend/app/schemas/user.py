from pydantic import BaseModel, Field
from typing import List, Optional


class UserProfileInput(BaseModel):
    """Data yang dikirim saat mengupdate profil setelah onboarding."""
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    handle: Optional[str] = Field(None, description="@username untuk profil")
    bio: Optional[str] = Field(None, description="Bio singkat")
    photo_url: Optional[str] = Field(None, description="URL foto profil dari Cloudinary")
    skills: List[str] = Field(default_factory=list, description="Daftar skill/keahlian")
    social_links: Optional[dict] = Field(None, description="Link sosial media: {github, linkedin, ...}")
