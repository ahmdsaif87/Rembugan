import os
import re
import json
import asyncio
import jwt as jwt_lib
from app.core.tasks import fire_and_forget
from datetime import datetime, timezone
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query, HTTPException, UploadFile, File
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database_sql import get_db_session, async_session_factory
from app.core.response import response_success
from app.core.security import verify_token
from app.core.constants import CHAT_HISTORY_MAX, NOTIF_GROUP_TAG, NOTIF_CHAT, NOTIF_FILE_UPLOADED
from app.models import User, Message, Project, ProjectMember
from app.services.chat_manager import manager
from app.services.notification import notify
from app.services.storage import upload_image_to_cloudinary
from app.services.chat_service import ChatService
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

    # Verify project membership or DM room authorization
    async with async_session_factory() as session:
        if room_id.isdigit():
            project_id = int(room_id)
            proj = (await session.execute(select(Project).where(Project.id == project_id))).scalar_one_or_none()
            if proj and proj.owner_id == user_id:
                pass
            else:
                stmt = select(ProjectMember).where(
                    ProjectMember.project_id == project_id,
                    ProjectMember.user_id == user_id,
                )
                is_member = (await session.execute(stmt)).scalar_one_or_none()
                if not is_member:
                    await websocket.close(code=4003, reason="Bukan anggota proyek ini")
                    return
        elif room_id.startswith("dm_"):
            parts = room_id.split("_")
            if len(parts) >= 3:
                if user_id not in (parts[1], parts[2]):
                    await websocket.close(code=4003, reason="Tidak diizinkan masuk room DM ini")
                    return

    await manager.connect(websocket, room_id, user_id)

    try:
        async with async_session_factory() as session:
            stmt = select(User).where(User.id == user_id)
            sender = (await session.execute(stmt)).scalar_one_or_none()
            sender_name = sender.full_name if sender else "Seseorang"

        while True:
            try:
                raw = await asyncio.wait_for(websocket.receive_text(), timeout=70)
            except asyncio.TimeoutError:
                break
            if raw == "ping":
                await websocket.send_text("pong")
                continue
            now = datetime.now(timezone.utc)

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

            logger.info(f"=== WS RECEIVED from {user_id} in {room_id} ({msg_type}, {len(text)} chars)")

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

            async with async_session_factory() as ws_session:
                if room_id.isdigit():
                    project_id = int(room_id)
                    msg = Message(
                        content=text, type=msg_type,
                        sender_id=user_id, project_id=project_id,
                        attachment_url=attachment_url,
                        attachment_name=attachment_name,
                        attachment_size=attachment_size,
                        reply_to_id=reply_to_id,
                    )
                    ws_session.add(msg)
                    await ws_session.commit()

                    service = ChatService(ws_session)
                    await manager.broadcast(pesan, room_id)

                    fire_and_forget(
                        service._broadcast_feed_group(user_id, project_id, room_id, text[:80], now),
                        "broadcast_feed_group"
                    )

                    if msg_type == "text":
                        mentions = re.findall(r'@(\w+)', text)
                        if mentions:
                            fire_and_forget(
                                service._handle_mentions(user_id, project_id, text[:30], mentions),
                                "handle_mentions"
                            )

                else:
                    parts = room_id.split("_")
                    receiver_id = (
                        parts[2] if len(parts) >= 3 and parts[1] == user_id
                        else (parts[1] if len(parts) >= 2 else None)
                    )

                    msg = Message(
                        content=text, type=msg_type,
                        sender_id=user_id, receiver_id=receiver_id,
                        attachment_url=attachment_url,
                        attachment_name=attachment_name,
                        attachment_size=attachment_size,
                        reply_to_id=reply_to_id,
                    )
                    ws_session.add(msg)
                    await ws_session.commit()

                    service = ChatService(ws_session)
                    await manager.broadcast(pesan, room_id)

                    if receiver_id:
                        fire_and_forget(
                            service._broadcast_feed_dm(user_id, receiver_id, room_id, text[:80], now),
                            "broadcast_feed_dm"
                        )

                    if receiver_id and msg_type == "text":
                        fire_and_forget(
                            service._handle_dm_notification(user_id, receiver_id, text[:30], room_id),
                            "handle_dm_notification"
                        )

    except WebSocketDisconnect:
        pass
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

    await manager.connect(websocket, "_feed_", user_id)

    try:
        while True:
            try:
                data = await asyncio.wait_for(websocket.receive_text(), timeout=70)
            except asyncio.TimeoutError:
                break
            if data == "ping":
                await websocket.send_text("pong")
    except WebSocketDisconnect:
        pass
    manager.disconnect(websocket, "_feed_", user_id)


@router.post("/dm/upload/{receiver_id}", summary="Upload File ke DM")
async def upload_dm_file(
    receiver_id: str,
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
    service: ChatService = Depends(ChatService),
):
    uid = user_token.get("uid")
    data = await service.upload_dm_file(uid, receiver_id, file)
    return response_success(data)


@router.get("/rooms", summary="Daftar Room Chat Saya")
async def get_my_rooms(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    service: ChatService = Depends(ChatService),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")
    skip = (page - 1) * limit
    data = await service.get_my_rooms(uid, skip=skip, limit=limit)
    return response_success(data)


@router.post("/rooms/{room_id}/read", summary="Tandai Room Sudah Dibaca")
async def mark_room_read(
    room_id: str,
    service: ChatService = Depends(ChatService),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")
    await service.mark_room_read(uid, room_id)
    return response_success(message="Room marked as read")


@router.get("/history/{room_id}", summary="Ambil Riwayat Chat")
async def get_chat_history(
    room_id: str,
    limit: int = Query(50, ge=1, le=CHAT_HISTORY_MAX),
    before_id: int | None = Query(None, description="Ambil pesan sebelum ID ini (cursor)"),
    service: ChatService = Depends(ChatService),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")
    data = await service.get_chat_history(uid, room_id, limit, before_id=before_id)
    return response_success(data)
