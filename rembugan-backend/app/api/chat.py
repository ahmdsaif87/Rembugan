from datetime import datetime, timezone, UTC
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query, HTTPException
from typing import Dict, List
from prisma import Prisma
from zoneinfo import ZoneInfo

from app.core.database import get_db

router = APIRouter(prefix="/chat", tags=["5. Real-time Chat"])


class ConnectionManager:
    """Manager untuk menyimpan koneksi WebSocket aktif per room."""
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str):
        await websocket.accept()
        if room_id not in self.active_connections:
            self.active_connections[room_id] = []
        self.active_connections[room_id].append(websocket)

    def disconnect(self, websocket: WebSocket, room_id: str):
        if room_id in self.active_connections:
            self.active_connections[room_id].remove(websocket)
            if not self.active_connections[room_id]:
                del self.active_connections[room_id]

    async def broadcast(self, message: dict, room_id: str):
        if room_id in self.active_connections:
            for connection in self.active_connections[room_id]:
                await connection.send_json(message)


manager = ConnectionManager()


@router.websocket("/ws/{room_id}/{user_id}")
async def websocket_chat(websocket: WebSocket, room_id: str, user_id: str):
    """
    WebSocket endpoint untuk real-time chat.
    room_id bisa berupa project_id (group chat) atau format DM.
    Setiap pesan disimpan ke database.
    """
    db = await get_db()
    await manager.connect(websocket, room_id)
    try:
        while True:
            data = await websocket.receive_text()
            now = datetime.now(timezone.utc)

            # Simpan pesan ke database
            try:
                # Cek apakah room_id adalah project (angka) atau DM
                if room_id.isdigit():
                    await db.message.create(data={
                        "content": data, "sender_id": user_id,
                        "project_id": int(room_id),
                    })
                else:
                    # DM: room_id format "dm_{user1}_{user2}"
                    parts = room_id.split("_")
                    receiver_id = parts[2] if len(parts) >= 3 and parts[1] == user_id else (parts[1] if len(parts) >= 2 else None)
                    await db.message.create(data={
                        "content": data, "sender_id": user_id,
                        "receiver_id": receiver_id,
                    })
            except Exception as e:
                print(f"Gagal simpan pesan ke DB: {e}")

            pesan_terformat = {
                "sender_id": user_id,
                "text": data,
                "timestamp": now.isoformat(),
            }
            await manager.broadcast(pesan_terformat, room_id)

    except WebSocketDisconnect:
        manager.disconnect(websocket, room_id)


@router.get("/history/{room_id}", summary="Ambil Riwayat Chat")
async def get_chat_history(
    room_id: str,
    limit: int = Query(50, ge=1, le=200),
    db: Prisma = Depends(get_db),
):
    """Ambil riwayat pesan dari sebuah room (project group chat atau DM)."""
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
            "created_at": msg.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        })

    return {"status": "success", "room_id": room_id, "data": result}