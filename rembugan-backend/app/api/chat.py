import os
import re
import json
import asyncio
import jwt as jwt_lib
from datetime import datetime, timezone
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query, HTTPException, UploadFile, File
from prisma import Prisma
from app.core.dates import tz_iso

from app.core.database import get_db
from app.core.security import verify_token
from app.core.constants import CHAT_HISTORY_MAX, NOTIF_GROUP_TAG, NOTIF_CHAT, NOTIF_FILE_UPLOADED
from app.services.chat_manager import manager
from app.services.notification import notify
from app.services.storage import upload_image_to_cloudinary
from app.core.logger import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/chat", tags=["5. Real-time Chat"])


@router.websocket("/ws/{room_id}")
async def websocket_chat(
    websocket: WebSocket,
    room_id: str,
    token: str = Query(...),
):
    try:
        jwt_secret = os.getenv("JWT_SECRET_KEY")
        payload = jwt_lib.decode(token, jwt_secret, algorithms=["HS256"])
        user_id = payload["uid"]
    except Exception:
        await websocket.close(code=4001, reason="Token tidak valid")
        return

    db = await get_db()
    await manager.connect(websocket, room_id, user_id)

    try:
        sender = await db.user.find_unique(where={"id": user_id})
        sender_name = sender.full_name if sender else "Seseorang"

        while True:
            raw = await websocket.receive_text()
            now = datetime.now(timezone.utc)

            # Support JSON payload untuk file messages
            try:
                data = json.loads(raw)
                text = data.get("text", "")
                msg_type = data.get("type", "text")
                attachment_url = data.get("attachment_url")
                attachment_name = data.get("attachment_name")
                attachment_size = data.get("attachment_size")
                reply_to_id = data.get("reply_to_id")
            except json.JSONDecodeError:
                text = raw
                msg_type = "text"
                attachment_url = None
                attachment_name = None
                attachment_size = None
                reply_to_id = None

            pesan = {
                "sender_id": user_id,
                "sender_name": sender_name,
                "text": text,
                "type": msg_type,
                "attachment_url": attachment_url,
                "attachment_name": attachment_name,
                "attachment_size": attachment_size,
                "timestamp": now.isoformat(),
            }

            if room_id.isdigit():
                project_id = int(room_id)
                save_task = asyncio.create_task(
                    db.message.create(data={
                        "content": text, "type": msg_type,
                        "sender_id": user_id, "project_id": project_id,
                        "attachment_url": attachment_url,
                        "attachment_name": attachment_name,
                        "attachment_size": attachment_size,
                        "reply_to_id": reply_to_id,
                    })
                )

                await manager.broadcast(pesan, room_id)

                # Feed broadcast — group member lain
                asyncio.create_task(
                    _broadcast_feed_group(db, user_id, project_id, room_id, text[:80], now)
                )

                if msg_type == "text":
                    mentions = re.findall(r'@(\w+)', text)
                    if mentions:
                        asyncio.create_task(
                            _handle_mentions(db, user_id, project_id, text[:30], mentions)
                        )

                try:
                    await save_task
                except Exception as e:
                    logger.error(f"Gagal simpan chat group: {e}")

            else:
                parts = room_id.split("_")
                receiver_id = (
                    parts[2] if len(parts) >= 3 and parts[1] == user_id
                    else (parts[1] if len(parts) >= 2 else None)
                )

                save_task = asyncio.create_task(
                    db.message.create(data={
                        "content": text, "type": msg_type,
                        "sender_id": user_id, "receiver_id": receiver_id,
                        "attachment_url": attachment_url,
                        "attachment_name": attachment_name,
                        "attachment_size": attachment_size,
                        "reply_to_id": reply_to_id,
                    })
                )

                await manager.broadcast(pesan, room_id)

                # Feed broadcast — DM receiver
                if receiver_id:
                    asyncio.create_task(
                        _broadcast_feed_dm(user_id, receiver_id, room_id, text[:80], now)
                    )

                if receiver_id and msg_type == "text":
                    asyncio.create_task(
                        _handle_dm_notification(db, user_id, receiver_id, text[:30], room_id)
                    )

                try:
                    await save_task
                except Exception as e:
                    logger.error(f"Gagal simpan chat DM: {e}")

    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id, user_id)


@router.websocket("/ws/feed")
async def websocket_feed(
    websocket: WebSocket,
    token: str = Query(...),
):
    try:
        jwt_secret = os.getenv("JWT_SECRET_KEY")
        payload = jwt_lib.decode(token, jwt_secret, algorithms=["HS256"])
        user_id = payload["uid"]
    except Exception:
        await websocket.close(code=4001, reason="Token tidak valid")
        return

    # Daftarkan ke user_connections tanpa room_id (feed saja)
    await manager.connect(websocket, "_feed_", user_id)

    try:
        while True:
            data = await websocket.receive_text()
            # Feed WS hanya menerima (tidak mengirim pesan ke sini)
            # Keepalive / ignore
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        manager.disconnect(websocket, "_feed_", user_id)


async def _handle_mentions(db: Prisma, sender_id: str, project_id: int, preview: str, mentions: list[str]):
    try:
        sender = await db.user.find_unique(where={"id": sender_id})
        sender_name = sender.full_name if sender else "Seseorang"
        project = await db.project.find_unique(where={"id": project_id})
        project_title = project.title if project else "Proyek"
        for mention in mentions:
            mentioned_user = await db.user.find_first(
                where={"full_name": {"contains": mention, "mode": "insensitive"}}
            )
            if mentioned_user and mentioned_user.id != sender_id:
                await notify(
                    db, mentioned_user.id, NOTIF_GROUP_TAG,
                    f"Anda dimention di grup '{project_title}'",
                    f"{sender_name} men-tag anda: {preview}",
                    f"/workspace/{project_id}",
                )
    except Exception as e:
        logger.error(f"Gagal proses mention: {e}")


async def _broadcast_feed_group(db: Prisma, sender_id: str, project_id: int, room_id: str, preview: str, now: datetime):
    try:
        members = await db.projectmember.find_many(where={"project_id": project_id})
        feed = {
            "event": "feed_message",
            "room_id": room_id,
            "type": "group",
            "sender_id": sender_id,
            "text": preview,
            "timestamp": now.isoformat(),
        }
        for m in members:
            if m.user_id != sender_id:
                await manager.send_to_user(m.user_id, feed)
    except Exception as e:
        logger.error(f"Gagal broadcast feed group: {e}")


async def _broadcast_feed_dm(sender_id: str, receiver_id: str, room_id: str, preview: str, now: datetime):
    try:
        feed = {
            "event": "feed_message",
            "room_id": room_id,
            "type": "dm",
            "sender_id": sender_id,
            "text": preview,
            "timestamp": now.isoformat(),
        }
        await manager.send_to_user(receiver_id, feed)
    except Exception as e:
        logger.error(f"Gagal broadcast feed DM: {e}")


async def _handle_dm_notification(db: Prisma, sender_id: str, receiver_id: str, preview: str, room_id: str):
    try:
        sender = await db.user.find_unique(where={"id": sender_id})
        sender_name = sender.full_name if sender else "Seseorang"
        await notify(
            db, receiver_id, NOTIF_CHAT,
            f"Pesan baru dari {sender_name}",
            preview,
            f"/chat/{room_id}",
        )
    except Exception as e:
        logger.error(f"Gagal proses notif DM: {e}")


@router.post("/dm/upload/{receiver_id}", summary="Upload File ke DM")
async def upload_dm_file(
    receiver_id: str,
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    if uid == receiver_id:
        raise HTTPException(status_code=400, detail="Tidak bisa kirim file ke diri sendiri")

    content = await file.read()
    size = len(content)
    if size > 50 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="File terlalu besar (maks 50MB)")

    url = upload_image_to_cloudinary(content, folder_name="rembugan_chat_files")

    msg = await db.message.create(data={
        "content": file.filename or "File",
        "type": "file",
        "sender_id": uid,
        "receiver_id": receiver_id,
        "attachment_url": url,
        "attachment_name": file.filename,
        "attachment_size": size,
    })

    room_id = f"dm_{min(uid, receiver_id)}_{max(uid, receiver_id)}"
    payload = {
        "sender_id": uid,
        "text": f"Mengirim file: {file.filename}",
        "type": "file",
        "attachment_url": url,
        "attachment_name": file.filename,
        "attachment_size": size,
        "timestamp": msg.created_at.isoformat(),
    }
    await manager.broadcast(payload, room_id)

    asyncio.create_task(
        _broadcast_feed_dm(uid, receiver_id, room_id, f"Mengirim file: {file.filename}", msg.created_at)
    )

    sender = await db.user.find_unique(where={"id": uid})
    await notify(
        db, receiver_id, NOTIF_CHAT,
        f"File baru dari {sender.full_name if sender else 'Seseorang'}",
        file.filename or "File",
        f"/chat/{room_id}",
    )

    return {
        "status": "success",
        "data": {
            "id": msg.id,
            "name": file.filename,
            "url": url,
            "size": size,
        },
    }


@router.get("/rooms", summary="Daftar Room Chat Saya")
async def get_my_rooms(
    db: Prisma = Depends(get_db),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")

    # Ambil read status semua room user
    read_states = await db.roomread.find_many(where={"user_id": uid})
    read_map = {r.room_id: r.last_read_at for r in read_states}

    # Hanya DM saja (exclude group/workspace chat)
    messages = await db.message.find_many(
        where={
            "project_id": None,
            "OR": [
                {"sender_id": uid},
                {"receiver_id": uid},
            ]
        },
        include={"sender": True, "receiver": True},
        order={"created_at": "desc"},
    )

    seen = set()
    rooms = []
    for m in messages:
        if not m.receiver_id:
            continue
        other_id = m.receiver_id if m.sender_id == uid else m.sender_id
        other = m.receiver if m.sender_id == uid else m.sender
        sorted_ids = "_".join(sorted([uid, other_id]))
        room_id = f"dm_{sorted_ids}"

        if room_id not in seen:
            seen.add(room_id)
            last_read = read_map.get(room_id)
            unread_where = {"sender_id": other_id, "receiver_id": uid}
            if last_read:
                unread_where["created_at"] = {"gt": last_read}
            unread = await db.message.count(where=unread_where)

            rooms.append({
                "room_id": room_id,
                "type": "dm",
                "name": other.full_name if other else "User",
                "other_user_id": other_id,
                "photo_url": other.photo_url if other else None,
                "last_message": m.content[:80] if m.content else "",
                "last_time": tz_iso(m.created_at),
                "unread": unread,
            })

    return {"status": "success", "data": rooms}


@router.post("/rooms/{room_id}/read", summary="Tandai Room Sudah Dibaca")
async def mark_room_read(
    room_id: str,
    db: Prisma = Depends(get_db),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")
    await db.roomread.upsert(
        where={"user_id_room_id": {"user_id": uid, "room_id": room_id}},
        data={
            "create": {"user_id": uid, "room_id": room_id},
            "update": {"last_read_at": datetime.now(timezone.utc)},
        },
    )
    return {"status": "success"}


@router.get("/history/{room_id}", summary="Ambil Riwayat Chat")
async def get_chat_history(
    room_id: str,
    limit: int = Query(50, ge=1, le=CHAT_HISTORY_MAX),
    db: Prisma = Depends(get_db),
    _user_token: dict = Depends(verify_token),
):
    if room_id.isdigit():
        messages = await db.message.find_many(
            where={"project_id": int(room_id)},
            include={"sender": True},
            order={"created_at": "asc"},
            take=limit,
        )
    else:
        parts = room_id.split("_")
        if len(parts) >= 3:
            user1, user2 = parts[1], parts[2]
            messages = await db.message.find_many(
                where={
                    "OR": [
                        {"sender_id": user1, "receiver_id": user2},
                        {"sender_id": user2, "receiver_id": user1},
                    ]
                },
                include={"sender": True},
                order={"created_at": "asc"},
                take=limit,
            )
        else:
            raise HTTPException(status_code=400, detail="Format room_id tidak valid.")

    result = []
    for msg in messages:
        result.append({
            "id": msg.id,
            "content": msg.content,
            "type": msg.type,
            "sender_id": msg.sender_id,
            "sender_name": msg.sender.full_name if msg.sender else None,
            "attachment_url": msg.attachment_url,
            "attachment_name": msg.attachment_name,
            "attachment_size": msg.attachment_size,
            "reply_to_id": msg.reply_to_id,
            "created_at": tz_iso(msg.created_at),
        })

    return {"status": "success", "room_id": room_id, "data": result}
