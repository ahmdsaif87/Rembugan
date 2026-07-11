from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, func
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database_sql import Base


class Skill(Base):
    __tablename__ = "Skill"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(255), unique=True)

    users = relationship("UserSkill", back_populates="skill", lazy="selectin")


class UserSkill(Base):
    __tablename__ = "UserSkill"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"), primary_key=True)
    skill_id: Mapped[int] = mapped_column(ForeignKey("Skill.id", ondelete="CASCADE"), primary_key=True)

    user = relationship("User", back_populates="skills")
    skill = relationship("Skill", back_populates="users")


class Experience(Base):
    __tablename__ = "Experience"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("User.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String(255))
    company: Mapped[str] = mapped_column(String(255))
    description: Mapped[str | None] = mapped_column(String(1000), nullable=True)
    start_date: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    end_date: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    user = relationship("User", back_populates="experiences")
