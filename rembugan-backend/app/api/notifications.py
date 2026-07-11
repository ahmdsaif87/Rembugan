from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.response import response_success
from app.core.security import verify_token
from app.services.notifications_service import NotificationsService
from app.models.social import DeviceToken

router = APIRouter(prefix="/notifications", tags=["Notifikasi"])


class FCMTokenInput(BaseModel):
    token: str
    platform: str = "unknown"


@router.post("/fcm-token", summary="Daftarkan FCM Token untuk Push Notification")
async def register_fcm_token(
    body: FCMTokenInput,
    user_token: dict = Depends(verify_token),
    session: AsyncSession = Depends(get_db_session),
):
    user_id = user_token["uid"]
    # Hapus semua token lama user, simpan yang baru
    await session.execute(
        delete(DeviceToken).where(DeviceToken.user_id == user_id)
    )
    dt = DeviceToken(user_id=user_id, token=body.token, platform=body.platform)
    session.add(dt)
    await session.commit()
    return response_success(message="FCM token registered")


@router.delete("/fcm-token", summary="Hapus FCM Token")
async def unregister_fcm_token(
    token: str,
    user_token: dict = Depends(verify_token),
    session: AsyncSession = Depends(get_db_session),
):
    user_id = user_token["uid"]
    result = await session.execute(
        select(DeviceToken).where(
            DeviceToken.user_id == user_id,
            DeviceToken.token == token,
        )
    )
    dt = result.scalar_one_or_none()
    if dt:
        await session.delete(dt)
        await session.commit()
    return response_success(message="FCM token removed")


@router.get("/", summary="Lihat Semua Notifikasi")
async def list_notifications(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: NotificationsService = Depends(),
):
    data, total = await svc.list_notifications(user_token["uid"], (page - 1) * limit, limit)
    return response_success({"data": data, "total": total, "page": page, "limit": limit})


@router.get("/unread-count", summary="Jumlah Notifikasi Belum Dibaca")
async def unread_count(
    user_token: dict = Depends(verify_token),
    svc: NotificationsService = Depends(),
):
    count = await svc.get_unread_count(user_token["uid"])
    return response_success({"unread_count": count})


@router.put("/read-all", summary="Tandai Semua Notifikasi Telah Dibaca")
async def read_all_notifications(
    user_token: dict = Depends(verify_token),
    svc: NotificationsService = Depends(),
):
    await svc.mark_all_read(user_token["uid"])
    return response_success(message="Semua notifikasi ditandai telah dibaca")


@router.put("/{notification_id}/read", summary="Tandai Notifikasi Telah Dibaca")
async def read_notification(
    notification_id: int,
    user_token: dict = Depends(verify_token),
    svc: NotificationsService = Depends(),
):
    await svc.mark_read(notification_id, user_token["uid"])
    return response_success(message="Notifikasi ditandai telah dibaca")
