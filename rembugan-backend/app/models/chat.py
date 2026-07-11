from datetime import datetime
from sqlalchemy import String, DateTime, Integer, Text, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database_sql import Base


class Message(Base):
    __tablename__ = "Message"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    content: Mapped[str] = mapped_column(Text)
    type: Mapped[str] = mapped_column(String(20), default="text")
    sender_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    attachment_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    attachment_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    attachment_size: Mapped[int | None] = mapped_column(Integer, nullable=True)
    reply_to_id: Mapped[int | None] = mapped_column(ForeignKey("Message.id", ondelete="SET NULL"), nullable=True)
    receiver_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"), nullable=True)
    project_id: Mapped[int | None] = mapped_column(ForeignKey("Project.id", ondelete="CASCADE"), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())

    sender = relationship("User", foreign_keys=[sender_id], lazy="selectin")
    receiver = relationship("User", foreign_keys=[receiver_id], lazy="selectin")


class RoomRead(Base):
    __tablename__ = "RoomRead"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    room_id: Mapped[str] = mapped_column(String(255))
    last_read_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
