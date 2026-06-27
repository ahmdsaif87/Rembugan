import asyncio
from typing import Dict, List
from fastapi import WebSocket


class ConnectionManager:
    """Manager untuk koneksi WebSocket — track per room & per user."""

    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}
        self.user_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str, user_id: str):
        await websocket.accept()
        self.active_connections.setdefault(room_id, []).append(websocket)
        self.user_connections.setdefault(user_id, []).append(websocket)

    def disconnect(self, websocket: WebSocket, room_id: str, user_id: str):
        if room_id in self.active_connections:
            self.active_connections[room_id].remove(websocket)
            if not self.active_connections[room_id]:
                del self.active_connections[room_id]
        if user_id in self.user_connections:
            self.user_connections[user_id].remove(websocket)
            if not self.user_connections[user_id]:
                del self.user_connections[user_id]

    async def broadcast(self, message: dict, room_id: str):
        if room_id in self.active_connections:
            await asyncio.gather(
                *(c.send_json(message) for c in self.active_connections[room_id][:]),
                return_exceptions=True,
            )

    async def send_to_user(self, user_id: str, message: dict):
        """Kirim pesan ke semua koneksi user tertentu (untuk notif real-time)."""
        if user_id in self.user_connections:
            await asyncio.gather(
                *(c.send_json(message) for c in self.user_connections[user_id][:]),
                return_exceptions=True,
            )


manager = ConnectionManager()
