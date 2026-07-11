from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from app.core.database import get_db
from app.core.response import response_success
from app.core.security import verify_token
from app.services.notifications_service import NotificationsService
from prisma import Prisma

router = APIRouter(prefix="/notifications", tags=["Notifikasi"])


class FCMTokenInput(BaseModel):
    token: str
    platform: str = "unknown"


@router.post("/fcm-token", summary="Daftarkan FCM Token untuk Push Notification")
async def register_fcm_token(
    body: FCMTokenInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    user_id = user_token["uid"]
    existing = await db.devicetoken.find_first(
        where={"user_id": user_id, "token": body.token},
    )
    if existing:
        await db.devicetoken.update(
            where={"id": existing.id},
            data={"platform": body.platform},
        )
    else:
        await db.devicetoken.create(data={
            "user_id": user_id,
            "token": body.token,
            "platform": body.platform,
        })
    return response_success(message="FCM token registered")


@router.delete("/fcm-token", summary="Hapus FCM Token")
async def unregister_fcm_token(
    token: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    user_id = user_token["uid"]
    await db.devicetoken.delete_many(
        where={"user_id": user_id, "token": token},
    )
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
