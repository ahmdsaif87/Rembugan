from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db


class NotificationsService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def list_notifications(self, user_id: str, skip: int, limit: int) -> tuple[list[dict], int]:
        total = await self.db.notification.count(where={"user_id": user_id})
        notifications = await self.db.notification.find_many(
            where={"user_id": user_id},
            order={"created_at": "desc"},
            skip=skip,
            take=limit,
        )
        result = []
        for n in notifications:
            result.append({
                "id": n.id,
                "type": n.type,
                "title": n.title,
                "content": n.content,
                "is_read": n.is_read,
                "link": n.link,
                "created_at": n.created_at.isoformat(),
            })
        return result, total

    async def get_unread_count(self, user_id: str) -> int:
        return await self.db.notification.count(
            where={"user_id": user_id, "is_read": False}
        )

    async def mark_all_read(self, user_id: str):
        await self.db.notification.update_many(
            where={"user_id": user_id, "is_read": False},
            data={"is_read": True},
        )

    async def mark_read(self, notification_id: int, user_id: str):
        notif = await self.db.notification.find_unique(where={"id": notification_id})
        if not notif:
            raise HTTPException(status_code=404, detail="Notifikasi tidak ditemukan")
        if notif.user_id != user_id:
            raise HTTPException(status_code=403, detail="Akses ditolak")
        await self.db.notification.update(
            where={"id": notification_id},
            data={"is_read": True},
        )
