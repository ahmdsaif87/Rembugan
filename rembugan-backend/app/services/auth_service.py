from datetime import datetime, timezone
from fastapi import Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.security import hash_password, verify_password, create_jwt_token
from app.core.constants import ROLE_ADMIN
from app.core.types import AuthData
from app.models import User
from app.services.otp import send_otp_to_email, verify_otp_code


class AuthService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def register(self, nim: str, password: str, full_name: str, major: str) -> AuthData:
        result = await self.session.execute(select(User).where(User.nim == nim))
        existing = result.scalar_one_or_none()
        if existing:
            raise HTTPException(status_code=400, detail="NIM sudah terdaftar.")

        now = datetime.now(timezone.utc)
        user = User(
            nim=nim,
            password=hash_password(password),
            full_name=full_name,
            major=major,
            created_at=now,
            updated_at=now,
        )
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)

        token = create_jwt_token(user.id, user.email)
        return {
            "access_token": token,
            "token_type": "bearer",
            "user_id": user.id,
            "full_name": user.full_name,
            "handle": user.handle,
            "is_onboarded": user.is_onboarded,
        }

    async def register_verify_otp(self, email: str, otp: str):
        result = await self.session.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="Email tidak ditemukan.")
        if user.email_verified:
            raise HTTPException(status_code=400, detail="Email sudah diverifikasi.")

        await verify_otp_code(self.session, user.id, user.email, otp)
        user.email_verified = True
        await self.session.commit()

    async def login(self, identifier: str, password: str) -> AuthData:
        if "@" in identifier:
            result = await self.session.execute(select(User).where(User.email == identifier))
        else:
            result = await self.session.execute(select(User).where(User.nim == identifier))
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(status_code=401, detail="NIM/Email atau password salah.")

        if not user.email_verified and not user.nim:
            raise HTTPException(
                status_code=403,
                detail="Email belum diverifikasi. Silakan verifikasi email terlebih dahulu.",
            )

        if not verify_password(password, user.password):
            raise HTTPException(status_code=401, detail="NIM/Email atau password salah.")

        token = create_jwt_token(user.id, user.email or user.nim or "")
        return {
            "access_token": token,
            "token_type": "bearer",
            "user_id": user.id,
            "full_name": user.full_name,
            "handle": user.handle,
            "is_onboarded": user.is_onboarded,
            "interest": user.interest,
            "nim": user.nim,
            "faculty": user.faculty,
            "major": user.major,
            "email": user.email,
        }

    async def admin_login(self, email: str, password: str) -> AuthData:
        result = await self.session.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()
        if not user or not user.is_admin or not verify_password(password, user.password):
            raise HTTPException(status_code=401, detail="Email atau password admin salah.")
        token = create_jwt_token(user.id, email, role=ROLE_ADMIN)
        return {
            "access_token": token,
            "token_type": "bearer",
            "user_id": user.id,
            "full_name": user.full_name,
        }

    async def send_otp(self, user_id: str, email: str):
        result = await self.session.execute(select(User).where(User.email == email))
        existing = result.scalar_one_or_none()
        if existing and existing.id != user_id:
            raise HTTPException(status_code=400, detail="Email sudah digunakan oleh akun lain.")
        return await send_otp_to_email(self.session, user_id, email)

    async def verify_otp(self, user_id: str, email: str, otp: str) -> AuthData:
        await verify_otp_code(self.session, user_id, email, otp)
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if user:
            user.email = email
            user.email_verified = True
            await self.session.commit()
        return {"email": email, "email_verified": True}

    async def forgot_password_send_otp(self, nim: str):
        result = await self.session.execute(select(User).where(User.nim == nim))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="NIM tidak ditemukan.")
        if not user.email or not user.email_verified:
            raise HTTPException(
                status_code=400,
                detail="Akun ini belum memiliki email terverifikasi. Silakan hubungi admin untuk reset password.",
            )
        await send_otp_to_email(self.session, user.id, user.email)

    async def forgot_password_reset(self, nim: str, otp: str, new_password: str):
        result = await self.session.execute(select(User).where(User.nim == nim))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="NIM tidak ditemukan.")
        if not user.email or not user.email_verified:
            raise HTTPException(
                status_code=400,
                detail="Akun ini belum memiliki email terverifikasi. Silakan hubungi admin untuk reset password.",
            )
        await verify_otp_code(self.session, user.id, user.email, otp)
        user.password = hash_password(new_password)
        await self.session.commit()

    async def get_me(self, user_id: str) -> AuthData:
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan.")
        return {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "handle": user.handle,
            "email": user.email,
            "email_verified": user.email_verified,
            "is_onboarded": user.is_onboarded,
            "faculty": user.faculty,
            "major": user.major,
        }
