from fastapi import Depends, HTTPException
from sqlalchemy import select, func, update
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.models.social import Notification


class NotificationsService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def list_notifications(self, user_id: str, skip: int, limit: int) -> tuple[list[dict], int]:
        result = await self.session.execute(
            select(func.count(Notification.id)).where(Notification.user_id == user_id)
        )
        total = result.scalar() or 0

        result = await self.session.execute(
            select(Notification)
            .where(Notification.user_id == user_id)
            .order_by(Notification.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        notifications = result.scalars().all()

        result_data = []
        for n in notifications:
            result_data.append({
                "id": n.id,
                "type": n.type,
                "title": n.title,
                "content": n.content,
                "is_read": n.is_read,
                "link": n.link,
                "created_at": n.created_at.isoformat(),
            })
        return result_data, total

    async def get_unread_count(self, user_id: str) -> int:
        result = await self.session.execute(
            select(func.count(Notification.id)).where(
                Notification.user_id == user_id,
                Notification.is_read == False,
            )
        )
        return result.scalar() or 0

    async def mark_all_read(self, user_id: str):
        result = await self.session.execute(
            select(Notification).where(
                Notification.user_id == user_id,
                Notification.is_read == False,
            )
        )
        notifications = result.scalars().all()
        for n in notifications:
            n.is_read = True
        await self.session.commit()

    async def mark_read(self, notification_id: int, user_id: str):
        result = await self.session.execute(
            select(Notification).where(Notification.id == notification_id)
        )
        notif = result.scalar_one_or_none()
        if not notif:
            raise HTTPException(status_code=404, detail="Notifikasi tidak ditemukan")
        if notif.user_id != user_id:
            raise HTTPException(status_code=403, detail="Akses ditolak")
        notif.is_read = True
        await self.session.commit()
