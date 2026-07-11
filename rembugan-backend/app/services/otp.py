from datetime import datetime, timezone, timedelta
from fastapi import HTTPException
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.constants import OTP_MAX_PER_HOUR, OTP_EXPIRY_MINUTES, OTP_MAX_ATTEMPTS
from app.models.auth import OtpCode
from app.services.email import generate_otp, hash_otp, send_otp_email


async def send_otp_to_email(
    session: AsyncSession,
    user_id: str,
    email: str,
):
    """Generate, save, and send OTP — with per-user rate limit."""
    one_hour_ago = datetime.now(timezone.utc) - timedelta(hours=1)
    result = await session.execute(
        select(func.count(OtpCode.id)).where(
            OtpCode.user_id == user_id,
            OtpCode.email == email,
            OtpCode.used == False,
            OtpCode.created_at >= one_hour_ago,
        )
    )
    recent = result.scalar() or 0
    if recent >= OTP_MAX_PER_HOUR:
        raise HTTPException(
            status_code=429,
            detail="Terlalu banyak permintaan OTP. Coba lagi dalam 1 jam.",
        )

    otp = generate_otp()
    record = OtpCode(
        user_id=user_id,
        email=email,
        code_hash=hash_otp(otp),
        expires_at=datetime.now(timezone.utc) + timedelta(minutes=OTP_EXPIRY_MINUTES),
    )
    session.add(record)
    await session.commit()

    await send_otp_email(email, otp)
    return email


async def verify_otp_code(
    session: AsyncSession,
    user_id: str,
    email: str,
    otp: str,
):
    """Verify OTP for a user+email — increments attempts on failure."""
    result = await session.execute(
        select(OtpCode).where(
            OtpCode.user_id == user_id,
            OtpCode.email == email,
            OtpCode.used == False,
            OtpCode.expires_at >= datetime.now(timezone.utc),
        ).order_by(OtpCode.created_at.desc()).limit(1)
    )
    record = result.scalar_one_or_none()

    if not record:
        raise HTTPException(status_code=400, detail="Kode OTP tidak valid atau sudah kadaluarsa.")

    if record.attempts >= OTP_MAX_ATTEMPTS:
        raise HTTPException(status_code=400, detail="Terlalu banyak percobaan salah. Minta OTP baru.")

    if hash_otp(otp) != record.code_hash:
        record.attempts += 1
        await session.commit()
        raise HTTPException(status_code=400, detail="Kode OTP salah.")

    record.used = True
    await session.commit()
