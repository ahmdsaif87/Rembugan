from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, Request
from prisma import Prisma
from app.core.security import hash_password, verify_password, create_jwt_token, verify_token, verify_admin_credentials
from app.core.database import get_db
from app.core.rate_limit import limiter
from app.core.constants import ROLE_ADMIN
from app.schemas.auth import (
    RegisterInput, LoginInput, AdminLoginInput,
    SendOtpInput, VerifyOtpInput, ForgotPasswordSendOtpInput,
    ForgotPasswordResetInput, AdminCreateUserInput,
)
from app.services.otp import send_otp_to_email, verify_otp_code
from app.services.email import send_otp_email

router = APIRouter(prefix="/auth", tags=["0. Authentication"])


@router.post("/register", summary="Register User Baru (NIM + Password)")
@limiter.limit("5/minute")
async def register(
    request: Request,
    data: RegisterInput,
    db: Prisma = Depends(get_db),
):
    existing = await db.user.find_unique(where={"nim": data.nim})
    if existing:
        raise HTTPException(status_code=400, detail="NIM sudah terdaftar.")

    user = await db.user.create(
        data={
            "nim": data.nim,
            "password": hash_password(data.password),
            "full_name": data.full_name,
            "major": data.major,
        }
    )

    token = create_jwt_token(user.id, user.email)

    return {
        "status": "success",
        "message": f"Registrasi berhasil! Selamat datang, {user.full_name}.",
        "data": {
            "access_token": token,
            "token_type": "bearer",
            "user_id": user.id,
            "full_name": user.full_name,
            "handle": user.handle,
            "is_onboarded": user.is_onboarded,
        },
    }


@router.post("/login", summary="Login via NIM atau Email + Password")
@limiter.limit("10/minute")
async def login(
    request: Request,
    data: LoginInput,
    db: Prisma = Depends(get_db),
):
    if "@" in data.identifier:
        user = await db.user.find_first(
            where={"email": data.identifier, "email_verified": True}
        )
    else:
        user = await db.user.find_unique(where={"nim": data.identifier})

    if not user:
        raise HTTPException(status_code=401, detail="NIM/Email atau password salah.")

    if user.email and not user.email_verified:
        raise HTTPException(
            status_code=403,
            detail="Email belum diverifikasi. Silakan verifikasi email terlebih dahulu.",
        )

    if not verify_password(data.password, user.password):
        raise HTTPException(status_code=401, detail="NIM/Email atau password salah.")

    token = create_jwt_token(user.id, user.email)

    return {
        "status": "success",
        "message": f"Login berhasil! Halo, {user.full_name}.",
        "data": {
            "access_token": token,
            "token_type": "bearer",
            "user_id": user.id,
            "full_name": user.full_name,
            "handle": user.handle,
            "is_onboarded": user.is_onboarded,
        },
    }


@router.post("/admin-login", summary="Login Admin Dashboard")
@limiter.limit("10/minute")
async def admin_login(
    request: Request,
    data: AdminLoginInput,
):
    if not verify_admin_credentials(data.email, data.password):
        raise HTTPException(status_code=401, detail="Email atau password admin salah.")

    token = create_jwt_token("admin", data.email, role=ROLE_ADMIN)

    return {
        "status": "success",
        "message": "Login admin berhasil!",
        "data": {
            "access_token": token,
            "token_type": "bearer",
            "user_id": "admin",
            "full_name": "Admin",
        },
    }


@router.post("/email/send-otp", summary="Kirim OTP Verifikasi Email")
@limiter.limit("3/minute")
async def send_otp(
    request: Request,
    data: SendOtpInput,
    db: Prisma = Depends(get_db),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")

    existing_email = await db.user.find_unique(where={"email": data.email})
    if existing_email and existing_email.id != uid:
        raise HTTPException(status_code=400, detail="Email sudah digunakan oleh akun lain.")

    email = await send_otp_to_email(db, uid, data.email)
    return {
        "status": "success",
        "message": f"Kode OTP berhasil dikirim ke {email}.",
    }


@router.post("/email/verify-otp", summary="Verifikasi OTP Email")
@limiter.limit("5/minute")
async def verify_otp(
    request: Request,
    data: VerifyOtpInput,
    db: Prisma = Depends(get_db),
    user_token: dict = Depends(verify_token),
):
    uid = user_token.get("uid")

    await verify_otp_code(db, uid, data.email, data.otp)

    await db.user.update(
        where={"id": uid},
        data={"email": data.email, "email_verified": True},
    )

    return {
        "status": "success",
        "message": "Email berhasil diverifikasi! Sekarang kamu bisa login menggunakan email.",
        "data": {
            "email": data.email,
            "email_verified": True,
        },
    }


@router.post("/forgot-password/send-otp", summary="Kirim OTP Reset Password via NIM")
@limiter.limit("3/minute")
async def forgot_password_send_otp(
    request: Request,
    data: ForgotPasswordSendOtpInput,
    db: Prisma = Depends(get_db),
):
    user = await db.user.find_unique(where={"nim": data.nim})
    if not user:
        raise HTTPException(status_code=404, detail="NIM tidak ditemukan.")

    if not user.email or not user.email_verified:
        raise HTTPException(
            status_code=400,
            detail="Akun ini belum memiliki email terverifikasi. Silakan hubungi admin untuk reset password.",
        )

    await send_otp_to_email(db, user.id, user.email)
    return {
        "status": "success",
        "message": f"Kode OTP berhasil dikirim ke {user.email}.",
    }


@router.post("/forgot-password/reset", summary="Reset Password via OTP")
@limiter.limit("5/minute")
async def forgot_password_reset(
    request: Request,
    data: ForgotPasswordResetInput,
    db: Prisma = Depends(get_db),
):
    user = await db.user.find_unique(where={"nim": data.nim})
    if not user:
        raise HTTPException(status_code=404, detail="NIM tidak ditemukan.")

    if not user.email or not user.email_verified:
        raise HTTPException(
            status_code=400,
            detail="Akun ini belum memiliki email terverifikasi. Silakan hubungi admin untuk reset password.",
        )

    await verify_otp_code(db, user.id, user.email, data.otp)

    await db.user.update(
        where={"id": user.id},
        data={"password": hash_password(data.new_password)},
    )

    return {
        "status": "success",
        "message": "Password berhasil direset. Silakan login dengan password baru.",
    }


@router.get("/me", summary="Cek Data User yang Sedang Login")
async def get_current_user(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    user = await db.user.find_unique(where={"id": uid})

    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan.")

    return {
        "status": "success",
        "data": {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "handle": user.handle,
            "email": user.email,
            "email_verified": user.email_verified,
            "is_onboarded": user.is_onboarded,
        },
    }
