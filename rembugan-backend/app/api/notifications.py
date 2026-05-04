from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from zoneinfo import ZoneInfo
from app.core.database import get_db
from app.core.security import verify_token

router = APIRouter(prefix="/notifications", tags=["Notifikasi"])

@router.get("/", summary="Lihat Semua Notifikasi")
async def get_notifications(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    notifications = await db.notification.find_many(
        where={"user_id": uid},
        order={"created_at": "desc"}
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
            "created_at": n.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat()
        })
        
    return {"status": "success", "data": result}

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
