from fastapi import APIRouter, Depends, HTTPException
from prisma import Prisma
from firebase_admin import auth as firebase_auth

from app.core.security import hash_password, verify_password, create_jwt_token, verify_token
from app.core.database import get_db
from app.schemas.auth import RegisterInput, LoginInput, LinkGoogleInput, TokenResponse

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
    # Cek NIM sudah terdaftar?
    existing = await db.user.find_unique(where={"nim": data.nim})
    if existing:
        raise HTTPException(status_code=400, detail="NIM sudah terdaftar.")

    # Hash password & simpan user
    hashed = hash_password(data.password)
    user = await db.user.create(
        data={
            "nim": data.nim,
            "password": hashed,
            "full_name": data.full_name,
        }
    )

    # Generate JWT token
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


@router.post("/login", summary="Login via NIM + Password")
async def login(
    data: LoginInput,
    db: Prisma = Depends(get_db),
):
    """
    Login menggunakan NIM dan password.
    Jika berhasil, return JWT access token.
    """
    user = await db.user.find_unique(where={"nim": data.nim})
    if not user:
        raise HTTPException(status_code=401, detail="NIM atau password salah.")

    if not verify_password(data.password, user.password):
        raise HTTPException(status_code=401, detail="NIM atau password salah.")

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

    # Decode Firebase token dari Google Sign-In
    try:
        decoded_firebase = firebase_auth.verify_id_token(data.firebase_token)
    except Exception:
        raise HTTPException(status_code=400, detail="Firebase token tidak valid.")

    google_id = decoded_firebase.get("uid")
    google_email = decoded_firebase.get("email")

    # Cek apakah Google ID sudah ditautkan ke user lain
    existing = await db.user.find_first(where={"googleId": google_id})
    if existing and existing.id != uid:
        raise HTTPException(status_code=400, detail="Akun Google ini sudah ditautkan ke user lain.")

    # Update user dengan Google credentials
    user = await db.user.update(
        where={"id": uid},
        data={
            "googleId": google_id,
            "email": google_email,
        },
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
            "google_linked": user.googleId is not None,
            "is_onboarded": user.is_onboarded,
        },
    }
