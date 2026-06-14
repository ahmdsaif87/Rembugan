from prisma import Prisma
from app.core.logger import get_logger

logger = get_logger(__name__)


async def notify(
    db: Prisma,
    user_id: str,
    type_: str,
    title: str,
    content: str,
    link: str | None = None,
):
    """Create notification in background."""
    try:
        await db.notification.create(data={
            "user_id": user_id,
            "type": type_,
            "title": title,
            "content": content,
            "link": link,
        })
    except Exception as e:
        logger.error(f"Gagal kirim notif ke {user_id}: {e}")
