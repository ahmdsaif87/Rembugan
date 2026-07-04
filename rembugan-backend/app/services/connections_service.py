from dataclasses import dataclass
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.constants import CON_PENDING, CON_ACCEPTED, CON_REJECTED, NOTIF_CONN_REQUEST, NOTIF_CONN_ACCEPTED
from app.services.base import BaseService
from app.services.notification import notify


@dataclass
class ConnectionsService(BaseService):
    db: Prisma = Depends(get_db)

    async def get_my_connections(self, user_id: str, skip: int = 0, limit: int = 20):
        connections = await self.db.connection.find_many(
            where={
                "OR": [
                    {"sender_id": user_id, "status": CON_ACCEPTED},
                    {"receiver_id": user_id, "status": CON_ACCEPTED},
                ]
            },
            include={"sender": True, "receiver": True},
            skip=skip,
            take=limit,
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
                "interest": other.interest,
                "created_at": conn.created_at.isoformat(),
            })

        return result

    async def get_incoming(self, user_id: str, skip: int = 0, limit: int = 20):
        requests = await self.db.connection.find_many(
            where={"receiver_id": user_id, "status": CON_PENDING},
            include={"sender": True},
            order={"created_at": "desc"},
            skip=skip,
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
                "interest": req.sender.interest,
                "created_at": req.created_at.isoformat(),
            })

        return result

    async def get_sent(self, user_id: str, skip: int = 0, limit: int = 20):
        requests = await self.db.connection.find_many(
            where={"sender_id": user_id, "status": CON_PENDING},
            include={"receiver": True},
            order={"created_at": "desc"},
            skip=skip,
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
                "interest": req.receiver.interest,
                "created_at": req.created_at.isoformat(),
            })

        return result

    async def get_user_connections(self, user_id: str, target_user_id: str):
        connections = await self.db.connection.find_many(
            where={
                "OR": [
                    {"sender_id": target_user_id, "status": CON_ACCEPTED},
                    {"receiver_id": target_user_id, "status": CON_ACCEPTED},
                ]
            },
            include={"sender": True, "receiver": True},
        )

        result = []
        for conn in connections:
            other = conn.receiver if conn.sender_id == target_user_id else conn.sender
            result.append({
                "id": conn.id,
                "user_id": other.id,
                "full_name": other.full_name,
                "handle": other.handle,
                "photo_url": other.photo_url,
                "interest": other.interest,
                "created_at": conn.created_at.isoformat(),
            })

        return result

    async def send_request(self, sender_id: str, receiver_id: str):
        if sender_id == receiver_id:
            raise HTTPException(status_code=400, detail="Tidak bisa terhubung dengan diri sendiri.")

        existing = await self.db.connection.find_first(
            where={
                "OR": [
                    {"sender_id": sender_id, "receiver_id": receiver_id},
                    {"sender_id": receiver_id, "receiver_id": sender_id},
                ]
            }
        )
        if existing:
            raise HTTPException(status_code=400, detail=f"Koneksi sudah ada dengan status: {existing.status}")

        conn = await self.db.connection.create(
            data={"sender_id": sender_id, "receiver_id": receiver_id, "status": CON_PENDING}
        )

        sender = await self.db.user.find_unique(where={"id": sender_id})
        await notify(
            self.db, receiver_id, NOTIF_CONN_REQUEST,
            "Permintaan Koneksi Baru",
            f"{sender.full_name} ingin terhubung dengan Anda.",
            f"/connection/{conn.id}",
        )

        return {"message": "Permintaan terkirim"}

    async def accept_request(self, connection_id: int, user_id: str):
        conn = await self.db.connection.find_unique(where={"id": connection_id})
        if not conn:
            raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")

        if conn.receiver_id != user_id:
            raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")

        if conn.status != CON_PENDING:
            raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")

        await self.db.connection.update(
            where={"id": connection_id},
            data={"status": CON_ACCEPTED}
        )

        receiver = await self.db.user.find_unique(where={"id": user_id})
        await notify(
            self.db, conn.sender_id, NOTIF_CONN_ACCEPTED,
            "Permintaan Koneksi Diterima",
            f"{receiver.full_name} menerima permintaan koneksi Anda.",
            f"/profile/{user_id}",
        )

        return {"message": "Koneksi diterima"}

    async def reject_request(self, connection_id: int, user_id: str):
        conn = await self.db.connection.find_unique(where={"id": connection_id})
        if not conn:
            raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")

        if conn.receiver_id != user_id:
            raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")

        if conn.status != CON_PENDING:
            raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")

        await self.db.connection.update(
            where={"id": connection_id},
            data={"status": CON_REJECTED}
        )

        return {"message": "Koneksi ditolak"}
