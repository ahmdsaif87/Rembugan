from pydantic import BaseModel, Field


class RegisterInput(BaseModel):
    """Data untuk registrasi admin user baru."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    major: str = Field(..., min_length=2, description="Program studi / jurusan")


class LoginInput(BaseModel):
    """Data untuk login via NIM atau Email + Password."""
    identifier: str = Field(..., description="NIM atau Email (email hanya untuk yang sudah diverifikasi)")
    password: str = Field(..., description="Password")


class AdminLoginInput(BaseModel):
    """Data untuk login admin dashboard."""
    email: str = Field(..., description="Email admin")
    password: str = Field(..., description="Password admin")


class LinkGoogleInput(BaseModel):
    """Data untuk menautkan akun Google ke profil yang sudah ada."""
    firebase_token: str = Field(..., description="ID Token dari Firebase Auth (Google Sign-In)")


class SendOtpInput(BaseModel):
    """Data untuk mengirim OTP ke email."""
    email: str = Field(..., description="Alamat email tujuan")


class VerifyOtpInput(BaseModel):
    """Data untuk verifikasi OTP."""
    email: str = Field(..., description="Alamat email")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")


class AdminCreateUserInput(BaseModel):
    """Data untuk admin membuat user baru."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    major: str = Field(..., min_length=2, description="Program studi / jurusan")


class TokenResponse(BaseModel):
    """Response berisi access token."""
    access_token: str
    token_type: str = "bearer"
    user_id: str
    full_name: str
