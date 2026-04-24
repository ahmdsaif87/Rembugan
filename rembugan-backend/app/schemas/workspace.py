from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, timezone, UTC


class TaskCreateInput(BaseModel):
    """Data untuk membuat tugas baru di Kanban."""
    title: str = Field(..., min_length=3, description="Judul tugas")
    assignee_id: Optional[str] = Field(None, description="ID user yang ditugaskan")


class TaskMoveInput(BaseModel):
    """Data untuk memindahkan kartu Kanban."""
    status: str = Field(..., pattern="^(todo|doing|done)$", description="Status baru: todo, doing, atau done")


class TaskResponse(BaseModel):
    """Response data tugas."""
    id: int
    project_id: int
    title: str
    status: str
    assignee_id: Optional[str] = None
    assignee_name: Optional[str] = None
    created_at: datetime
