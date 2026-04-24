from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, timezone, UTC


class PostCreateInput(BaseModel):
    """Data untuk membuat post/konten baru di feed."""
    content: str = Field(..., min_length=1, description="Isi konten post")
    media_url: Optional[str] = Field(None, description="URL media dari Cloudinary")


class PostResponse(BaseModel):
    """Response data post."""
    id: int
    user_id: str
    content: str
    media_url: Optional[str] = None
    ai_category: Optional[str] = None
    created_at: datetime
    author_name: Optional[str] = None


class ScoredProjectResponse(BaseModel):
    """Response proyek dengan match score."""
    id: int
    title: str
    description: str
    required_skills: List[str]
    status: str
    owner_name: Optional[str] = None
    match_score: int = 0
