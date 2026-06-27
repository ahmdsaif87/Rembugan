from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma
from app.core.dates import tz_iso
from app.core.database import get_db
from app.core.security import verify_token

router = APIRouter(prefix="/notifications", tags=["Notifikasi"])

@router.get("/", summary="Lihat Semua Notifikasi")
async def get_notifications(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    notifications = await db.notification.find_many(
        where={"user_id": uid},
        order={"created_at": "desc"},
        skip=(page - 1) * limit,
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
            "created_at": tz_iso(n.created_at)
        })
        
    return {"status": "success", "data": result}

@router.get("/unread-count", summary="Jumlah Notifikasi Belum Dibaca")
async def unread_count(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    count = await db.notification.count(
        where={"user_id": uid, "is_read": False}
    )
    return {"status": "success", "data": {"unread_count": count}}


@router.put("/read-all", summary="Tandai Semua Notifikasi Telah Dibaca")
async def read_all_notifications(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    await db.notification.update_many(
        where={"user_id": uid, "is_read": False},
        data={"is_read": True},
    )
    return {"status": "success", "message": "Semua notifikasi ditandai telah dibaca"}


@router.put("/{notification_id}/read", summary="Tandai Notifikasi Telah Dibaca")
async def read_notification(
    notification_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    notif = await db.notification.find_unique(where={"id": notification_id})
    if not notif:
        raise HTTPException(status_code=404, detail="Notifikasi tidak ditemukan")
        
    if notif.user_id != uid:
        raise HTTPException(status_code=403, detail="Akses ditolak")
        
    await db.notification.update(
        where={"id": notification_id},
        data={"is_read": True}
    )
    
    return {"status": "success", "message": "Notifikasi ditandai telah dibaca"}
