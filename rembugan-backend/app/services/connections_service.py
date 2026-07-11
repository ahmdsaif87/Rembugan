from dataclasses import dataclass
from fastapi import Depends, HTTPException
from sqlalchemy import select, or_, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import CON_PENDING, CON_ACCEPTED, CON_REJECTED, NOTIF_CONN_REQUEST, NOTIF_CONN_ACCEPTED
from app.models import User, Connection
from app.services.base import BaseService
from app.services.notification import notify


@dataclass
class ConnectionsService(BaseService):
    session: AsyncSession = Depends(get_db_session)

    async def get_my_connections(self, user_id: str, skip: int = 0, limit: int = 20):
        result = await self.session.execute(
            select(Connection).where(
                or_(
                    and_(Connection.sender_id == user_id, Connection.status == CON_ACCEPTED),
                    and_(Connection.receiver_id == user_id, Connection.status == CON_ACCEPTED),
                )
            ).offset(skip).limit(limit)
        )
        connections = result.scalars().all()

        other_ids = set()
        for conn in connections:
            other = conn.receiver_id if conn.sender_id == user_id else conn.sender_id
            other_ids.add(other)

        users_map = {}
        if other_ids:
            result = await self.session.execute(select(User).where(User.id.in_(other_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for conn in connections:
            other = users_map.get(conn.receiver_id if conn.sender_id == user_id else conn.sender_id)
            if not other:
                continue
            result_data.append({
                "id": conn.id,
                "user_id": other.id,
                "full_name": other.full_name,
                "handle": other.handle,
                "photo_url": other.photo_url,
                "interest": other.interest,
                "created_at": conn.created_at.isoformat(),
            })

        return result_data

    async def get_incoming(self, user_id: str, skip: int = 0, limit: int = 20):
        result = await self.session.execute(
            select(Connection)
            .where(Connection.receiver_id == user_id, Connection.status == CON_PENDING)
            .order_by(Connection.created_at.desc())
            .offset(skip).limit(limit)
        )
        requests = result.scalars().all()

        sender_ids = [r.sender_id for r in requests]
        users_map = {}
        if sender_ids:
            result = await self.session.execute(select(User).where(User.id.in_(sender_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for req in requests:
            s = users_map.get(req.sender_id)
            result_data.append({
                "id": req.id,
                "sender_id": req.sender_id,
                "full_name": s.full_name if s else None,
                "handle": s.handle if s else None,
                "photo_url": s.photo_url if s else None,
                "interest": s.interest if s else None,
                "created_at": req.created_at.isoformat(),
            })

        return result_data

    async def get_sent(self, user_id: str, skip: int = 0, limit: int = 20):
        result = await self.session.execute(
            select(Connection)
            .where(Connection.sender_id == user_id, Connection.status == CON_PENDING)
            .order_by(Connection.created_at.desc())
            .offset(skip).limit(limit)
        )
        requests = result.scalars().all()

        receiver_ids = [r.receiver_id for r in requests]
        users_map = {}
        if receiver_ids:
            result = await self.session.execute(select(User).where(User.id.in_(receiver_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for req in requests:
            r = users_map.get(req.receiver_id)
            result_data.append({
                "id": req.id,
                "receiver_id": req.receiver_id,
                "full_name": r.full_name if r else None,
                "handle": r.handle if r else None,
                "photo_url": r.photo_url if r else None,
                "interest": r.interest if r else None,
                "created_at": req.created_at.isoformat(),
            })

        return result_data

    async def get_user_connections(self, user_id: str, target_user_id: str):
        result = await self.session.execute(
            select(Connection).where(
                or_(
                    and_(Connection.sender_id == target_user_id, Connection.status == CON_ACCEPTED),
                    and_(Connection.receiver_id == target_user_id, Connection.status == CON_ACCEPTED),
                )
            )
        )
        connections = result.scalars().all()

        other_ids = set()
        for conn in connections:
            other = conn.receiver_id if conn.sender_id == target_user_id else conn.sender_id
            other_ids.add(other)

        users_map = {}
        if other_ids:
            result = await self.session.execute(select(User).where(User.id.in_(other_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        result_data = []
        for conn in connections:
            other = users_map.get(conn.receiver_id if conn.sender_id == target_user_id else conn.sender_id)
            if not other:
                continue
            result_data.append({
                "id": conn.id,
                "user_id": other.id,
                "full_name": other.full_name,
                "handle": other.handle,
                "photo_url": other.photo_url,
                "interest": other.interest,
                "created_at": conn.created_at.isoformat(),
            })

        return result_data

    async def send_request(self, sender_id: str, receiver_id: str):
        if sender_id == receiver_id:
            raise HTTPException(status_code=400, detail="Tidak bisa terhubung dengan diri sendiri.")

        result = await self.session.execute(
            select(Connection).where(
                or_(
                    and_(Connection.sender_id == sender_id, Connection.receiver_id == receiver_id),
                    and_(Connection.sender_id == receiver_id, Connection.receiver_id == sender_id),
                )
            )
        )
        existing = result.scalar_one_or_none()

        if existing:
            if existing.status == CON_REJECTED:
                existing.status = CON_PENDING
                existing.sender_id = sender_id
                existing.receiver_id = receiver_id
                await self.session.commit()
                conn = existing
            elif existing.status == CON_PENDING and existing.receiver_id == sender_id:
                existing.status = CON_ACCEPTED
                await self.session.commit()
                conn = existing
            else:
                raise HTTPException(status_code=400, detail=f"Koneksi sudah ada dengan status: {existing.status}")
        else:
            conn = Connection(sender_id=sender_id, receiver_id=receiver_id, status=CON_PENDING)
            self.session.add(conn)
            await self.session.commit()
            await self.session.refresh(conn)

        result = await self.session.execute(select(User).where(User.id == sender_id))
        sender = result.scalar_one_or_none()
        await notify(
            self.session, receiver_id, NOTIF_CONN_REQUEST,
            "Permintaan Koneksi Baru",
            f"{sender.full_name if sender else 'Seseorang'} ingin terhubung dengan Anda.",
            f"/connection/{conn.id}",
        )

        return {"message": "Permintaan terkirim"}

    async def accept_request(self, connection_id: int, user_id: str):
        result = await self.session.execute(select(Connection).where(Connection.id == connection_id))
        conn = result.scalar_one_or_none()
        if not conn:
            raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")

        if conn.receiver_id != user_id:
            raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")

        if conn.status != CON_PENDING:
            raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")

        conn.status = CON_ACCEPTED
        await self.session.commit()

        result = await self.session.execute(select(User).where(User.id == user_id))
        receiver = result.scalar_one_or_none()
        await notify(
            self.session, conn.sender_id, NOTIF_CONN_ACCEPTED,
            "Permintaan Koneksi Diterima",
            f"{receiver.full_name if receiver else 'Seseorang'} menerima permintaan koneksi Anda.",
            f"/profile/{user_id}",
        )

        return {"message": "Koneksi diterima"}

    async def reject_request(self, connection_id: int, user_id: str):
        result = await self.session.execute(select(Connection).where(Connection.id == connection_id))
        conn = result.scalar_one_or_none()
        if not conn:
            raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")

        if conn.receiver_id != user_id:
            raise HTTPException(status_code=403, detail="Anda bukan penerima permintaan ini")

        if conn.status != CON_PENDING:
            raise HTTPException(status_code=400, detail="Permintaan ini sudah diproses")

        conn.status = CON_REJECTED
        await self.session.commit()

        return {"message": "Koneksi ditolak"}

    async def cancel_request(self, user_id: str, receiver_id: str):
        result = await self.session.execute(
            select(Connection).where(
                Connection.sender_id == user_id,
                Connection.receiver_id == receiver_id,
                Connection.status == CON_PENDING,
            )
        )
        conn = result.scalar_one_or_none()
        if not conn:
            raise HTTPException(status_code=404, detail="Permintaan tidak ditemukan")

        await self.session.delete(conn)
        await self.session.commit()
        return {"message": "Permintaan dibatalkan"}

    async def remove_connection(self, user_id: str, other_user_id: str):
        result = await self.session.execute(
            select(Connection).where(
                or_(
                    and_(Connection.sender_id == user_id, Connection.receiver_id == other_user_id, Connection.status == CON_ACCEPTED),
                    and_(Connection.sender_id == other_user_id, Connection.receiver_id == user_id, Connection.status == CON_ACCEPTED),
                )
            )
        )
        conn = result.scalar_one_or_none()
        if not conn:
            raise HTTPException(status_code=404, detail="Koneksi tidak ditemukan")

        await self.session.delete(conn)
        await self.session.commit()
        return {"message": "Koneksi dihapus"}
