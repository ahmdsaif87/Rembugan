import os
from datetime import datetime, timedelta, timezone
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
import bcrypt
security = HTTPBearer()

# ==========================================
# KONFIGURASI — WAJIB SET DI ENVIRONMENT
# ==========================================
JWT_SECRET = os.getenv("JWT_SECRET_KEY")
if not JWT_SECRET:
    raise RuntimeError("JWT_SECRET_KEY wajib diset di environment variable! Jangan pakai default.")

JWT_ALGORITHM = "HS256"
JWT_EXPIRY_DAYS = 7

ADMIN_EMAIL = os.getenv("ADMIN_EMAIL")
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD")
if not ADMIN_EMAIL or not ADMIN_PASSWORD:
    raise RuntimeError("ADMIN_EMAIL dan ADMIN_PASSWORD wajib diset di environment variable!")


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
def create_jwt_token(user_id: str, email: str = None, role: str = None) -> str:
    """Generate JWT access token dengan expiry 7 hari."""
    payload = {
        "uid": user_id,
        "email": email,
        "exp": datetime.now(timezone.utc) + timedelta(days=JWT_EXPIRY_DAYS),
        "iat": datetime.now(timezone.utc),
    }
    if role:
        payload["role"] = role
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def _verify_jwt(token: str) -> dict:
    """Decode dan verifikasi JWT token. Raise exception jika gagal."""
    payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    result = {"uid": payload["uid"], "email": payload.get("email")}
    if payload.get("role"):
        result["role"] = payload["role"]
    return result


# ==========================================
# UNIFIED TOKEN VERIFIER
# ==========================================
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """
    Verifikasi JWT token dari header Authorization.

    Returns:
        dict: {"uid": "...", "email": "..."} 
    """
    token = credentials.credentials

    try:
        return _verify_jwt(token)
    except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak valid atau sudah kadaluarsa. Silakan login ulang.",
        )


# ==========================================
# ADMIN TOKEN VERIFIER
# ==========================================
def verify_admin_token(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """
    Verifikasi token admin dari header Authorization.
    Hanya menerima JWT dengan role: "admin".
    """
    token = credentials.credentials

    try:
        payload = _verify_jwt(token)
    except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token tidak valid atau sudah kadaluarsa.",
        )

    if payload.get("role") != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Akses ditolak. Hanya admin yang dapat mengakses resource ini.",
        )

    return payload


# ==========================================
# OPTIONAL TOKEN VERIFIER (untuk endpoint publik)
# ==========================================
def verify_token_optional(
    credentials: HTTPAuthorizationCredentials = Depends(
        HTTPBearer(auto_error=False)
    ),
) -> dict | None:
    """
    Sama seperti verify_token, tapi tidak raise error jika token tidak ada.
    Returns None jika tidak ada token, atau dict jika valid.
    """
    if credentials is None:
        return None
    token = credentials.credentials
    try:
        return _verify_jwt(token)
    except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
        return None


# ==========================================
# ADMIN CREDENTIAL VERIFIER
# ==========================================
def verify_admin_credentials(email: str, password: str) -> bool:
    """Verifikasi kredensial admin terhadap env var."""
    return email == ADMIN_EMAIL and password == ADMIN_PASSWORD