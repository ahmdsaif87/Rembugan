from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import async_session_factory
from app.core.dates import tz_iso
from app.core.logger import get_logger
from app.models.social import Notification, DeviceToken
from app.services.chat_manager import manager
from app.services.fcm_service import send_push_notification
from app.core.tasks import fire_and_forget

logger = get_logger(__name__)


async def notify(
    session: AsyncSession,
    user_id: str,
    type_: str,
    title: str,
    content: str,
    link: str | None = None,
):
    try:
        record = Notification(
            user_id=user_id,
            type=type_,
            title=title,
            content=content,
            link=link,
        )
        session.add(record)
        await session.commit()
        await session.refresh(record)

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
        fire_and_forget(_push_fcm(user_id, title, content, link))
    except Exception as e:
        logger.error(f"Gagal kirim notif ke {user_id}: {e}")


async def _push_fcm(
    user_id: str,
    title: str,
    body: str,
    link: str | None = None,
):
    try:
        async with async_session_factory() as session:
            result = await session.execute(
                select(DeviceToken).where(DeviceToken.user_id == user_id)
            )
            tokens = result.scalars().all()
            if not tokens:
                return
            data = {}
            if link:
                data["link"] = link
            for t in tokens:
                await send_push_notification(t.token, title, body, data)
    except Exception as e:
        logger.error(f"FCM push gagal untuk {user_id}: {e}")
