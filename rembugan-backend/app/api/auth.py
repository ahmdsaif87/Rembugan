from datetime import datetime, timezone, timedelta
from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from firebase_admin import auth as firebase_auth

from app.core.security import hash_password, verify_password, create_jwt_token, verify_token, verify_admin_token, verify_admin_credentials
from app.core.database import get_db
from app.schemas.auth import (
    RegisterInput, LoginInput, AdminLoginInput, LinkGoogleInput,
    SendOtpInput, VerifyOtpInput, AdminCreateUserInput, TokenResponse,
)
from app.services.email import generate_otp, hash_otp, send_otp_email

router = APIRouter(prefix="/auth", tags=["0. Authentication"])


@router.post("/register", summary="Register User Baru (NIM + Password)")
async def register(
    data: RegisterInput,
    db: Prisma = Depends(get_db),
):
    """
    Daftarkan user baru dengan NIM dan password.
    Password akan di-hash sebelum disimpan ke database.
    """
    existing = await db.user.find_unique(where={"nim": data.nim})
    if existing:
        raise HTTPException(status_code=400, detail="NIM sudah terdaftar.")

    hashed = hash_password(data.password)
    user = await db.user.create(
        data={
            "nim": data.nim,
            "password": hashed,
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
            "is_onboarded": user.is_onboarded,
        },
    }


@router.post("/login", summary="Login via NIM atau Email + Password")
async def login(
    data: LoginInput,
    db: Prisma = Depends(get_db),
):
    """
    Login menggunakan NIM atau Email (yang sudah diverifikasi) + Password.
    Jika berhasil, return JWT access token.
    """
    if "@" in data.identifier:
        user = await db.user.find_first(
            where={"email": data.identifier, "email_verified": True}
        )
    else:
        user = await db.user.find_unique(where={"nim": data.identifier})

    if not user:
        raise HTTPException(status_code=401, detail="NIM/Email atau password salah.")

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
            "is_onboarded": user.is_onboarded,
        },
    }


@router.post("/admin-login", summary="Login Admin Dashboard")
async def admin_login(
    data: AdminLoginInput,
):
    """
    Login untuk admin dashboard menggunakan email + password dari env.
    """
    if not verify_admin_credentials(data.email, data.password):
        raise HTTPException(status_code=401, detail="Email atau password admin salah.")

    token = create_jwt_token("admin", data.email, role="admin")

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


@router.post("/link-google", summary="Tautkan Akun Google ke Profil")
async def link_google_account(
    data: LinkGoogleInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    User yang sudah login (via JWT) bisa menautkan akun Google-nya.
    Setelah ditautkan, user bisa login via 2 jalur: NIM+Password ATAU Google.
    """
    uid = user_token.get("uid")

    try:
        decoded_firebase = firebase_auth.verify_id_token(data.firebase_token)
    except Exception:
        raise HTTPException(status_code=400, detail="Firebase token tidak valid.")

    google_id = decoded_firebase.get("uid")
    google_email = decoded_firebase.get("email")

    existing = await db.user.find_first(where={"googleId": google_id})
    if existing and existing.id != uid:
        raise HTTPException(status_code=400, detail="Akun Google ini sudah ditautkan ke user lain.")

    # Update googleId, dan set email jika belum ada
    update_data = {"googleId": google_id}
    if google_email:
        update_data["email"] = google_email
        update_data["email_verified"] = True

    user = await db.user.update(
        where={"id": uid},
        data=update_data,
    )

    return {
        "status": "success",
        "message": f"Akun Google ({google_email}) berhasil ditautkan!",
        "data": {
            "user_id": user.id,
            "email": user.email,
            "google_linked": True,
        },
    }


@router.post("/email/send-otp", summary="Kirim OTP Verifikasi Email")
async def send_otp(
    data: SendOtpInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Kirim kode OTP 6-digit ke email untuk verifikasi.
    Rate limit: max 3 OTP per jam per user.
    """
    uid = user_token.get("uid")

    existing_email = await db.user.find_unique(where={"email": data.email})
    if existing_email and existing_email.id != uid:
        raise HTTPException(status_code=400, detail="Email sudah digunakan oleh akun lain.")

    one_hour_ago = datetime.now(timezone.utc) - timedelta(hours=1)
    recent_count = await db.otpcode.count(
        where={
            "user_id": uid,
            "email": data.email,
            "used": False,
            "created_at": {"gte": one_hour_ago},
        }
    )
    if recent_count >= 3:
        raise HTTPException(
            status_code=429,
            detail="Terlalu banyak permintaan OTP. Coba lagi dalam 1 jam.",
        )

    otp = generate_otp()
    hashed = hash_otp(otp)

    await db.otpcode.create(
        data={
            "user_id": uid,
            "email": data.email,
            "code_hash": hashed,
            "expires_at": datetime.now(timezone.utc) + timedelta(minutes=5),
        }
    )

    send_otp_email(data.email, otp)

    return {
        "status": "success",
        "message": f"Kode OTP berhasil dikirim ke {data.email}.",
    }


@router.post("/email/verify-otp", summary="Verifikasi OTP Email")
async def verify_otp(
    data: VerifyOtpInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Verifikasi kode OTP untuk mengaktifkan email sebagai metode login.
    """
    uid = user_token.get("uid")

    otp_record = await db.otpcode.find_first(
        where={
            "user_id": uid,
            "email": data.email,
            "used": False,
            "expires_at": {"gte": datetime.now(timezone.utc)},
        },
        order={"created_at": "desc"},
    )

    if not otp_record:
        raise HTTPException(status_code=400, detail="Kode OTP tidak valid atau sudah kadaluarsa.")

    if otp_record.attempts >= 3:
        raise HTTPException(status_code=400, detail="Terlalu banyak percobaan salah. Minta OTP baru.")

    if hash_otp(data.otp) != otp_record.code_hash:
        await db.otpcode.update(
            where={"id": otp_record.id},
            data={"attempts": otp_record.attempts + 1},
        )
        raise HTTPException(status_code=400, detail="Kode OTP salah.")

    await db.otpcode.update(
        where={"id": otp_record.id},
        data={"used": True},
    )

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


@router.get("/me", summary="Cek Data User yang Sedang Login")
async def get_current_user(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil data user yang sedang login berdasarkan token."""
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
            "email": user.email,
            "email_verified": user.email_verified,
            "google_linked": user.googleId is not None,
            "is_onboarded": user.is_onboarded,
        },
    }
