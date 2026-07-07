from pydantic import BaseModel, Field
from typing import Optional, List


class CreatePostInput(BaseModel):
    type: str = Field(..., pattern="^(post|offer)$", description="'post' untuk postingan, 'offer' untuk tawaran proyek")

    content: Optional[str] = Field(None, min_length=1, description="Isi postingan")
    media_urls: Optional[List[str]] = Field(None, description="URL media (gambar)")
    tags: Optional[List[str]] = Field(None, description="Tag postingan")

    title: Optional[str] = Field(None, min_length=5, max_length=100, description="Nama proyek")
    description: Optional[str] = Field(None, min_length=20, description="Deskripsi proyek")
    required_skills: Optional[List[str]] = Field(None, min_length=1, description="Skill yang dibutuhkan")
    category: Optional[str] = Field(None, description="Kategori proyek")
    interest: Optional[str] = Field(None, description="Minat terkait proyek")
    total_slots: Optional[int] = Field(None, ge=1, description="Slot anggota tersisa")
    deadline: Optional[str] = Field(None, description="Batas waktu pendaftaran (ISO datetime)")


class SharePostInput(BaseModel):
    post_id: str = Field(..., description="ID dari showcase atau project")
    post_type: str = Field(..., pattern="^(post|offer)$", description="'post' atau 'offer'")
    friend_ids: List[str] = Field(..., description="Daftar user ID teman untuk dikirimi DM")
