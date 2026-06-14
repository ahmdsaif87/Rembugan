import asyncio
from typing import Dict, List
from fastapi import WebSocket


class ConnectionManager:
    """Manager untuk menyimpan koneksi WebSocket aktif per room."""

    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, room_id: str):
        await websocket.accept()
        self.active_connections.setdefault(room_id, []).append(websocket)

    def disconnect(self, websocket: WebSocket, room_id: str):
        if room_id in self.active_connections:
            self.active_connections[room_id].remove(websocket)
            if not self.active_connections[room_id]:
                del self.active_connections[room_id]

    async def broadcast(self, message: dict, room_id: str):
        if room_id in self.active_connections:
            await asyncio.gather(
                *(c.send_json(message) for c in self.active_connections[room_id][:]),
                return_exceptions=True,
            )


manager = ConnectionManager()
