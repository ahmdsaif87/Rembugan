from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.security import verify_token

router = APIRouter(prefix="/connections", tags=["Koneksi (Teman)"])

@router.post("/request/{receiver_id}", summary="Kirim Permintaan Koneksi")
async def send_connection_request(
    receiver_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    if uid == receiver_id:
        raise HTTPException(status_code=400, detail="Tidak dapat mengirim permintaan ke diri sendiri")
        
    receiver = await db.user.find_unique(where={"id": receiver_id})
    if not receiver:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
        
    # Cek apakah sudah ada koneksi
    existing = await db.connection.find_first(
        where={
            "OR": [
                {"sender_id": uid, "receiver_id": receiver_id},
                {"sender_id": receiver_id, "receiver_id": uid}
            ]
        }
    )
    
    if existing:
        raise HTTPException(status_code=400, detail=f"Koneksi sudah ada dengan status: {existing.status}")
        
    conn = await db.connection.create(
        data={
            "sender_id": uid,
            "receiver_id": receiver_id,
            "status": "pending"
        }
    )
    
    # Buat Notifikasi
    sender = await db.user.find_unique(where={"id": uid})
    await db.notification.create(
        data={
            "user_id": receiver_id,
            "type": "connection_request",
            "title": "Permintaan Koneksi Baru",
            "content": f"{sender.full_name} ingin terhubung dengan Anda.",
            "link": f"/profile/{uid}"
        }
    )
    
    return {"status": "success", "message": "Permintaan terkirim"}

@router.put("/accept/{connection_id}", summary="Terima Permintaan Koneksi")
async def accept_connection(
    connection_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    conn = await db.connection.find_unique(where={"id": connection_id})
    if not conn:
        raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")
        
    if conn.receiver_id != uid:
        raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")
        
    if conn.status != "pending":
        raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")
        
    await db.connection.update(
        where={"id": connection_id},
        data={"status": "accepted"}
    )
    
    # Buat Notifikasi ke pengirim
    receiver = await db.user.find_unique(where={"id": uid})
    await db.notification.create(
        data={
            "user_id": conn.sender_id,
            "type": "connection_accepted",
            "title": "Permintaan Koneksi Diterima",
            "content": f"{receiver.full_name} menerima permintaan koneksi Anda.",
            "link": f"/profile/{uid}"
        }
    )
    
    return {"status": "success", "message": "Koneksi diterima"}

@router.put("/reject/{connection_id}", summary="Tolak Permintaan Koneksi")
async def reject_connection(
    connection_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    conn = await db.connection.find_unique(where={"id": connection_id})
    if not conn:
        raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")
        
    if conn.receiver_id != uid:
        raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")
        
    await db.connection.update(
        where={"id": connection_id},
        data={"status": "rejected"}
    )
    
    return {"status": "success", "message": "Koneksi ditolak"}
