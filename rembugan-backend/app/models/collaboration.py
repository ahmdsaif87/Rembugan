import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Integer, Text, ForeignKey, ARRAY, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database_sql import Base


class Project(Base):
    __tablename__ = "Project"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    owner_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str] = mapped_column(Text)
    required_skills: Mapped[list[str]] = mapped_column(ARRAY(String(255)))
    status: Mapped[str] = mapped_column(String(20), default="open")
    category: Mapped[str | None] = mapped_column(String(100), nullable=True)
    deadline: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    total_slots: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    members = relationship("ProjectMember", back_populates="project", lazy="selectin")
    applications = relationship("ProjectApplication", back_populates="project", lazy="selectin")
    tasks = relationship("Task", back_populates="project", lazy="selectin")


class ProjectApplication(Base):
    __tablename__ = "ProjectApplication"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"))
    applicant_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    status: Mapped[str] = mapped_column(String(20), default="pending")
    applied_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    project = relationship("Project", back_populates="applications", lazy="selectin")


class ProjectMember(Base):
    __tablename__ = "ProjectMember"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    role: Mapped[str] = mapped_column(String(50), default="Anggota")

    project = relationship("Project", back_populates="members", lazy="selectin")
    user = relationship("User", lazy="selectin")


class ProjectInvite(Base):
    __tablename__ = "ProjectInvite"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    project_id: Mapped[int] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"))
    token: Mapped[str] = mapped_column(String(255), unique=True)
    created_by: Mapped[str] = mapped_column(String(36))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class SavedItem(Base):
    __tablename__ = "SavedItem"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    project_id: Mapped[int | None] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"), nullable=True)
    showcase_id: Mapped[str | None] = mapped_column(nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Task(Base):
    __tablename__ = "Task"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(String(20), default="todo")
    deadline: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    project = relationship("Project", back_populates="tasks", lazy="selectin")
    assignees = relationship("TaskAssignee", back_populates="task", lazy="selectin", cascade="all, delete-orphan")


class TaskAssignee(Base):
    __tablename__ = "TaskAssignee"

    task_id: Mapped[int] = mapped_column(ForeignKey("Task.id", ondelete="CASCADE"), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"), primary_key=True)

    task = relationship("Task", back_populates="assignees", lazy="selectin")
    user = relationship("User", lazy="selectin")
