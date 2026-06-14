from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, timezone, UTC


class TaskCreateInput(BaseModel):
    """Data untuk membuat tugas baru di Kanban."""
    title: str = Field(..., min_length=3, description="Judul tugas")
    assignee_id: Optional[str] = Field(None, description="ID user yang ditugaskan")
    deadline: Optional[datetime] = Field(None, description="Tenggat waktu tugas")


class TaskMoveInput(BaseModel):
    """Data untuk memindahkan kartu Kanban."""
    status: str = Field(..., pattern="^(todo|doing|done)$", description="Status baru: todo, doing, atau done")
