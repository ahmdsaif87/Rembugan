from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, Query
from prisma import Prisma
from app.core.database import get_db
from app.core.security import verify_token
from app.core.constants import CON_PENDING, CON_ACCEPTED, CON_REJECTED, NOTIF_CONN_REQUEST, NOTIF_CONN_ACCEPTED
from app.services.notification import notify

router = APIRouter(prefix="/connections", tags=["Koneksi (Teman)"])


@router.get("/", summary="Lihat Koneksi Saya (yang sudah accepted)")
async def get_my_connections(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    connections = await db.connection.find_many(
        where={
            "OR": [
                {"sender_id": uid, "status": CON_ACCEPTED},
                {"receiver_id": uid, "status": CON_ACCEPTED},
            ]
        },
        include={
            "sender": True,
            "receiver": True,
        },
        skip=(page - 1) * limit,
        take=limit,
    )

    result = []
    for conn in connections:
        other = conn.receiver if conn.sender_id == uid else conn.sender
        result.append({
            "id": conn.id,
            "user_id": other.id,
            "full_name": other.full_name,
            "handle": other.handle,
            "photo_url": other.photo_url,
            "major": other.major,
            "created_at": conn.created_at.isoformat(),
        })

    return {"status": "success", "data": result}


@router.get("/incoming", summary="Lihat Permintaan Koneksi Masuk")
async def get_incoming_requests(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    requests = await db.connection.find_many(
        where={"receiver_id": uid, "status": CON_PENDING},
        include={"sender": True},
        order={"created_at": "desc"},
        skip=(page - 1) * limit,
        take=limit,
    )

    result = []
    for req in requests:
        result.append({
            "id": req.id,
            "sender_id": req.sender_id,
            "full_name": req.sender.full_name,
            "handle": req.sender.handle,
            "photo_url": req.sender.photo_url,
            "major": req.sender.major,
            "created_at": req.created_at.isoformat(),
        })

    return {"status": "success", "data": result}


@router.get("/sent", summary="Lihat Permintaan Koneksi Terkirim")
async def get_sent_requests(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    requests = await db.connection.find_many(
        where={"sender_id": uid, "status": CON_PENDING},
        include={"receiver": True},
        order={"created_at": "desc"},
        skip=(page - 1) * limit,
        take=limit,
    )

    result = []
    for req in requests:
        result.append({
            "id": req.id,
            "receiver_id": req.receiver_id,
            "full_name": req.receiver.full_name,
            "handle": req.receiver.handle,
            "photo_url": req.receiver.photo_url,
            "major": req.receiver.major,
            "created_at": req.created_at.isoformat(),
        })

    return {"status": "success", "data": result}


@router.get("/{user_id}", summary="Lihat Koneksi User Lain")
async def get_user_connections(
    user_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    connections = await db.connection.find_many(
        where={
            "OR": [
                {"sender_id": user_id, "status": CON_ACCEPTED},
                {"receiver_id": user_id, "status": CON_ACCEPTED},
            ]
        },
        include={
            "sender": True,
            "receiver": True,
        }
    )

    result = []
    for conn in connections:
        other = conn.receiver if conn.sender_id == user_id else conn.sender
        result.append({
            "id": conn.id,
            "user_id": other.id,
            "full_name": other.full_name,
            "handle": other.handle,
            "photo_url": other.photo_url,
            "major": other.major,
            "created_at": conn.created_at.isoformat(),
        })

    return {"status": "success", "data": result}


@router.post("/send/{receiver_id}", summary="Kirim Permintaan Koneksi")
async def send_connection_request(
    receiver_id: str,
    background_tasks: BackgroundTasks,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")

    if uid == receiver_id:
        raise HTTPException(status_code=400, detail="Tidak bisa terhubung dengan diri sendiri.")

    existing = await db.connection.find_first(
        where={
            "OR": [
                {"sender_id": uid, "receiver_id": receiver_id},
                {"sender_id": receiver_id, "receiver_id": uid},
            ]
        }
    )
    if existing:
        raise HTTPException(status_code=400, detail=f"Koneksi sudah ada dengan status: {existing.status}")

    conn = await db.connection.create(
        data={"sender_id": uid, "receiver_id": receiver_id, "status": CON_PENDING}
    )

    sender = await db.user.find_unique(where={"id": uid})
    background_tasks.add_task(
        notify, db, receiver_id, NOTIF_CONN_REQUEST,
        "Permintaan Koneksi Baru",
        f"{sender.full_name} ingin terhubung dengan Anda.",
        f"/profile/{uid}",
    )

    return {"status": "success", "message": "Permintaan terkirim"}


@router.put("/accept/{connection_id}", summary="Terima Permintaan Koneksi")
async def accept_connection(
    connection_id: int,
    background_tasks: BackgroundTasks,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")

    conn = await db.connection.find_unique(where={"id": connection_id})
    if not conn:
        raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")

    if conn.receiver_id != uid:
        raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")

    if conn.status != CON_PENDING:
        raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")

    await db.connection.update(
        where={"id": connection_id},
        data={"status": CON_ACCEPTED}
    )

    receiver = await db.user.find_unique(where={"id": uid})
    background_tasks.add_task(
        notify, db, conn.sender_id, NOTIF_CONN_ACCEPTED,
        "Permintaan Koneksi Diterima",
        f"{receiver.full_name} menerima permintaan koneksi Anda.",
        f"/profile/{uid}",
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

    if conn.status != CON_PENDING:
        raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")

    await db.connection.update(
        where={"id": connection_id},
        data={"status": CON_REJECTED}
    )

    return {"status": "success", "message": "Koneksi ditolak"}
