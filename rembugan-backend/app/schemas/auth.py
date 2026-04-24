from pydantic import BaseModel, Field


class RegisterInput(BaseModel):
    """Data untuk registrasi user baru via NIM."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")


class LoginInput(BaseModel):
    """Data untuk login via NIM + Password."""
    nim: str = Field(..., description="NIM mahasiswa")
    password: str = Field(..., description="Password")


class LinkGoogleInput(BaseModel):
    """Data untuk menautkan akun Google ke profil yang sudah ada."""
    firebase_token: str = Field(..., description="ID Token dari Firebase Auth (Google Sign-In)")


class TokenResponse(BaseModel):
    """Response berisi access token."""
    access_token: str
    token_type: str = "bearer"
    user_id: str
    full_name: str
