from datetime import datetime, timezone, timedelta
from fastapi import HTTPException
from prisma import Prisma
from app.core.constants import OTP_MAX_PER_HOUR, OTP_EXPIRY_MINUTES, OTP_MAX_ATTEMPTS
from app.services.email import generate_otp, hash_otp, send_otp_email


async def send_otp_to_email(
    db: Prisma,
    user_id: str,
    email: str,
):
    """Generate, save, and send OTP — with per-user rate limit."""
    one_hour_ago = datetime.now(timezone.utc) - timedelta(hours=1)
    recent = await db.otpcode.count(
        where={
            "user_id": user_id,
            "email": email,
            "used": False,
            "created_at": {"gte": one_hour_ago},
        }
    )
    if recent >= OTP_MAX_PER_HOUR:
        raise HTTPException(
            status_code=429,
            detail="Terlalu banyak permintaan OTP. Coba lagi dalam 1 jam.",
        )

    otp = generate_otp()
    await db.otpcode.create(
        data={
            "user_id": user_id,
            "email": email,
            "code_hash": hash_otp(otp),
            "expires_at": datetime.now(timezone.utc) + timedelta(minutes=OTP_EXPIRY_MINUTES),
        }
    )

    await send_otp_email(email, otp)
    return email


async def verify_otp_code(
    db: Prisma,
    user_id: str,
    email: str,
    otp: str,
):
    """Verify OTP for a user+email — increments attempts on failure."""
    record = await db.otpcode.find_first(
        where={
            "user_id": user_id,
            "email": email,
            "used": False,
            "expires_at": {"gte": datetime.now(timezone.utc)},
        },
        order={"created_at": "desc"},
    )

    if not record:
        raise HTTPException(status_code=400, detail="Kode OTP tidak valid atau sudah kadaluarsa.")

    if record.attempts >= OTP_MAX_ATTEMPTS:
        raise HTTPException(status_code=400, detail="Terlalu banyak percobaan salah. Minta OTP baru.")

    if hash_otp(otp) != record.code_hash:
        await db.otpcode.update(
            where={"id": record.id},
            data={"attempts": record.attempts + 1},
        )
        raise HTTPException(status_code=400, detail="Kode OTP salah.")

    await db.otpcode.update(
        where={"id": record.id},
        data={"used": True},
    )
