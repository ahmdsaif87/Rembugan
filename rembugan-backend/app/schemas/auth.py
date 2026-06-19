from pydantic import BaseModel, Field
from typing import Optional


class RegisterInput(BaseModel):
    """Data untuk registrasi user baru."""
    email: str = Field(..., description="Email user")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    interest: Optional[str] = Field(None, description="Minat/bidang user")


class LoginInput(BaseModel):
    """Data untuk login via Email + Password."""
    email: str = Field(..., description="Email")
    password: str = Field(..., description="Password")


class AdminLoginInput(BaseModel):
    """Data untuk login admin dashboard."""
    email: str = Field(..., description="Email admin")
    password: str = Field(..., description="Password admin")


class SendOtpInput(BaseModel):
    """Data untuk mengirim OTP ke email."""
    email: str = Field(..., description="Alamat email tujuan")


class VerifyOtpInput(BaseModel):
    """Data untuk verifikasi OTP."""
    email: str = Field(..., description="Alamat email")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")


class ForgotPasswordSendOtpInput(BaseModel):
    """Data untuk minta OTP reset password via email."""
    email: str = Field(..., description="Email terdaftar")


class ForgotPasswordResetInput(BaseModel):
    """Data untuk reset password setelah verifikasi OTP."""
    email: str = Field(..., description="Email terdaftar")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")
    new_password: str = Field(..., min_length=6, description="Password baru minimal 6 karakter")


class AdminResetPasswordInput(BaseModel):
    """Data untuk admin reset password user."""
    email: str = Field(..., description="Email user")
    new_password: str = Field(..., min_length=6, description="Password baru minimal 6 karakter")


class AdminCreateUserInput(BaseModel):
    """Data untuk admin membuat user baru."""
    email: str = Field(..., description="Email user")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    interest: Optional[str] = Field(None, description="Minat/bidang user")


class RegisterVerifyOtpInput(BaseModel):
    """Data untuk verifikasi OTP saat registrasi."""
    email: str = Field(..., description="Alamat email")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")
