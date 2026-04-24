import os
from datetime import datetime, timedelta, timezone
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
import bcrypt
import firebase_admin
from firebase_admin import credentials, auth

security = HTTPBearer()

# ==========================================
# KONFIGURASI
# ==========================================
JWT_SECRET = os.getenv("JWT_SECRET_KEY", "fallback-secret-key")
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_DAYS = 7


# ==========================================
# FIREBASE SETUP
# ==========================================
def setup_firebase():
    if not firebase_admin._apps:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        root_dir = os.path.dirname(os.path.dirname(current_dir))
        cred_path = os.path.join(root_dir, "firebase-admin.json")

        if not os.path.exists(cred_path):
            raise FileNotFoundError(f"File Firebase tidak ditemukan di: {cred_path}")

        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)


# ==========================================
# PASSWORD HASHING (bcrypt)
# ==========================================
def hash_password(plain_password: str) -> str:
    """Hash password menggunakan bcrypt."""
    return bcrypt.hashpw(plain_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifikasi password terhadap hash bcrypt."""
    return bcrypt.checkpw(plain_password.encode("utf-8"), hashed_password.encode("utf-8"))


# ==========================================
# JWT TOKEN
# ==========================================
def create_jwt_token(user_id: str, email: str = None) -> str:
    """Generate JWT access token dengan expiry 7 hari."""
    payload = {
        "uid": user_id,
        "email": email,
        "exp": datetime.now(timezone.utc) + timedelta(days=JWT_EXPIRY_DAYS),
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def _verify_jwt(token: str) -> dict:
    """Decode dan verifikasi JWT token. Raise exception jika gagal."""
    payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    return {"uid": payload["uid"], "email": payload.get("email")}


# ==========================================
# UNIFIED TOKEN VERIFIER
# ==========================================
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """
    Verifikasi token dari header Authorization.
    Mendukung 2 jenis token:
      1. JWT (dari login NIM+Password)
      2. Firebase ID Token (dari login Google)

    Returns:
        dict: {"uid": "...", "email": "..."} 
    """
    token = credentials.credentials

    # 1. Coba decode sebagai JWT terlebih dahulu
    try:
        return _verify_jwt(token)
    except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
        pass  # Bukan JWT yang valid, coba Firebase

    # 2. Coba decode sebagai Firebase token
    try:
        decoded_token = auth.verify_id_token(token)
        return {
            "uid": decoded_token["uid"],
            "email": decoded_token.get("email"),
        }
    except Exception:
        pass  # Bukan Firebase token yang valid juga

    # 3. Kedua metode gagal
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token tidak valid atau sudah kadaluarsa. Silakan login ulang.",
    )