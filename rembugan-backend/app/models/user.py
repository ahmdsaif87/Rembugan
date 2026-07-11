import uuid
from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Text, JSON, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database_sql import Base


class User(Base):
    __tablename__ = "User"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    password: Mapped[str] = mapped_column(String(255))
    email_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    nim: Mapped[str | None] = mapped_column(String(50), unique=True, nullable=True)
    faculty: Mapped[str | None] = mapped_column(String(255), nullable=True)
    major: Mapped[str | None] = mapped_column(String(255), nullable=True)
    full_name: Mapped[str] = mapped_column(String(255))
    handle: Mapped[str | None] = mapped_column(String(255), unique=True, nullable=True)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    interest: Mapped[str | None] = mapped_column(String(500), nullable=True)
    photo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    cover_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    social_links: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    is_onboarded: Mapped[bool] = mapped_column(Boolean, default=False)
    is_admin: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    skills = relationship("UserSkill", back_populates="user", lazy="selectin")
    experiences = relationship("Experience", back_populates="user", lazy="selectin")
