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


class SendOtpInput(BaseModel):
    """Data untuk mengirim OTP ke email."""
    email: str = Field(..., description="Alamat email tujuan")


class VerifyOtpInput(BaseModel):
    """Data untuk verifikasi OTP."""
    email: str = Field(..., description="Alamat email")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")


class ForgotPasswordSendOtpInput(BaseModel):
    """Data untuk minta OTP reset password via NIM."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")


class ForgotPasswordResetInput(BaseModel):
    """Data untuk reset password setelah verifikasi OTP."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")
    new_password: str = Field(..., min_length=6, description="Password baru minimal 6 karakter")


class AdminResetPasswordInput(BaseModel):
    """Data untuk admin reset password user."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    new_password: str = Field(..., min_length=6, description="Password baru minimal 6 karakter")


class AdminCreateUserInput(BaseModel):
    """Data untuk admin membuat user baru."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    major: str = Field(..., min_length=2, description="Program studi / jurusan")



