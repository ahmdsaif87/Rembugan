from fastapi import APIRouter, Depends, Query
from app.core.response import response_success
from app.core.security import verify_token
from app.services.notifications_service import NotificationsService

router = APIRouter(prefix="/notifications", tags=["Notifikasi"])


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
