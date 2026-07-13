from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, timezone, UTC


class TaskCreateInput(BaseModel):
    """Data untuk membuat tugas baru di Kanban."""
    title: str = Field(..., min_length=1, description="Judul tugas")
    assignee_ids: list[str] = Field(default_factory=list, description="ID user yang ditugaskan")
    deadline: Optional[str] = Field(None, description="Tenggat waktu tugas (ISO string)")


class TaskMoveInput(BaseModel):
    """Data untuk memindahkan kartu Kanban."""
    status: str = Field(..., pattern="^(todo|doing|done)$", description="Status baru: todo, doing, atau done")


class TaskUpdateInput(BaseModel):
    """Data untuk mengedit tugas."""
    title: Optional[str] = Field(None, min_length=1, description="Judul tugas")
    assignee_ids: Optional[list[str]] = Field(None, description="ID user yang ditugaskan")
    deadline: Optional[str] = Field(None, description="Tenggat waktu tugas (ISO string)")
