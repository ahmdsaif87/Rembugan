from datetime import datetime
from sqlalchemy import String, Boolean, DateTime, Integer, Text, ForeignKey, ARRAY, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database_sql import Base


class Showcase(Base):
    __tablename__ = "Showcase"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    author_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    content: Mapped[str] = mapped_column(Text)
    media_urls: Mapped[list[str]] = mapped_column("media_urls", ARRAY(Text))
    tags: Mapped[list[str]] = mapped_column("tags", ARRAY(String(255)))
    linked_project_id: Mapped[int | None] = mapped_column(ForeignKey("Project.id", ondelete="SET NULL"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    likes = relationship("ShowcaseLike", back_populates="showcase", lazy="selectin")
    comments = relationship("ShowcaseComment", back_populates="showcase", lazy="selectin")


class ShowcaseLike(Base):
    __tablename__ = "ShowcaseLike"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    showcase_id: Mapped[str] = mapped_column(String(36), ForeignKey("Showcase.id", ondelete="CASCADE"))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    showcase = relationship("Showcase", back_populates="likes", lazy="selectin")


class ShowcaseComment(Base):
    __tablename__ = "ShowcaseComment"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    showcase_id: Mapped[str] = mapped_column(String(36), ForeignKey("Showcase.id", ondelete="CASCADE"))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    content: Mapped[str] = mapped_column(Text)
    parent_id: Mapped[int | None] = mapped_column(ForeignKey("ShowcaseComment.id", ondelete="CASCADE"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    showcase = relationship("Showcase", back_populates="comments", lazy="selectin")
    user = relationship("User", lazy="selectin")


class ProjectFile(Base):
    __tablename__ = "ProjectFile"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    project_id: Mapped[int] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    name: Mapped[str] = mapped_column(String(255))
    url: Mapped[str] = mapped_column(String(500))
    size: Mapped[int | None] = mapped_column(Integer, nullable=True)
    mime_type: Mapped[str | None] = mapped_column(String(100), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    uploader = relationship("User", lazy="selectin")


class Connection(Base):
    __tablename__ = "Connection"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    sender_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    receiver_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    status: Mapped[str] = mapped_column(String(20), default="pending")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class Notification(Base):
    __tablename__ = "Notification"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    type: Mapped[str] = mapped_column(String(50))
    title: Mapped[str] = mapped_column(String(255))
    content: Mapped[str] = mapped_column(Text)
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    link: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())


class DeviceToken(Base):
    __tablename__ = "DeviceToken"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    token: Mapped[str] = mapped_column(String(500))
    platform: Mapped[str] = mapped_column(String(20), default="unknown")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=func.now(), onupdate=func.now())
