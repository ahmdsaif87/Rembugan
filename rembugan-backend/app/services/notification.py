from app.core.dates import tz_iso
from prisma import Prisma
from app.core.logger import get_logger
from app.services.chat_manager import manager

logger = get_logger(__name__)


async def notify(
    db: Prisma,
    user_id: str,
    type_: str,
    title: str,
    content: str,
    link: str | None = None,
):
    """Create notification in background and push real-time via WebSocket."""
    try:
        record = await db.notification.create(data={
            "user_id": user_id,
            "type": type_,
            "title": title,
            "content": content,
            "link": link,
        })
        payload = {
            "event": "new_notification",
            "data": {
                "id": record.id,
                "type": record.type,
                "title": record.title,
                "content": record.content,
                "is_read": record.is_read,
                "link": record.link,
                "created_at": tz_iso(record.created_at),
            },
        }
        await manager.send_to_user(user_id, payload)
    except Exception as e:
        logger.error(f"Gagal kirim notif ke {user_id}: {e}")
