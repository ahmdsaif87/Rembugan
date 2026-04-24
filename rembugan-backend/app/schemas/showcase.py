from pydantic import BaseModel, Field
from typing import List, Optional

class ShowcaseCreateInput(BaseModel):
    isi_postingan: str = Field(..., min_length=10, description="Konten portfolio/showcase, minimal 10 karakter")
    media_urls: Optional[List[str]] = Field(default_factory=list, description="Daftar URL gambar/video")
    tags: Optional[List[str]] = Field(default_factory=list, description="Tag kategori portfolio")
    linked_project_id: Optional[int] = Field(None, description="ID Project terkait jika ada")
