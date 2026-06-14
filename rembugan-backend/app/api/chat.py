import os
import re
import asyncio
import jwt as jwt_lib
from datetime import datetime, timezone
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query, HTTPException
from prisma import Prisma
from zoneinfo import ZoneInfo
from app.core.dates import tz_iso

from app.core.database import get_db
from app.core.security import verify_token
from app.core.constants import CHAT_HISTORY_MAX, NOTIF_GROUP_TAG, NOTIF_CHAT
from app.services.chat_manager import manager
from app.services.notification import notify
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
    await manager.connect(websocket, room_id)

    try:
        while True:
            data = await websocket.receive_text()
            now = datetime.now(timezone.utc)

            pesan = {
                "sender_id": user_id,
                "text": data,
                "timestamp": now.isoformat(),
            }

            if room_id.isdigit():
                project_id = int(room_id)

                save_task = asyncio.create_task(
                    db.message.create(data={
                        "content": data, "sender_id": user_id,
                        "project_id": project_id,
                    })
                )

                await manager.broadcast(pesan, room_id)

                mentions = re.findall(r'@(\w+)', data)
                if mentions:
                    asyncio.create_task(
                        _handle_mentions(db, user_id, project_id, data[:30], mentions)
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
                        "content": data, "sender_id": user_id,
                        "receiver_id": receiver_id,
                    })
                )

                await manager.broadcast(pesan, room_id)

                if receiver_id:
                    asyncio.create_task(
                        _handle_dm_notification(db, user_id, receiver_id, data[:30], room_id)
                    )

                try:
                    await save_task
                except Exception as e:
                    logger.error(f"Gagal simpan chat DM: {e}")

    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id)


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
            "id": msg.id, "content": msg.content,
            "sender_id": msg.sender_id,
            "sender_name": msg.sender.full_name if msg.sender else None,
            "created_at": tz_iso(msg.created_at),
        })

    return {"status": "success", "room_id": room_id, "data": result}
