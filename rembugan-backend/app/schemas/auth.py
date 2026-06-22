from pydantic import BaseModel, Field


class RegisterInput(BaseModel):
    """Data untuk registrasi admin user baru."""
    nim: str = Field(..., min_length=5, description="NIM mahasiswa")
    password: str = Field(..., min_length=6, description="Password minimal 6 karakter")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    major: str = Field(..., min_length=2, description="Program studi / jurusan")


class LoginInput(BaseModel):
    """Data untuk login via NIM atau Email + Password."""
<<<<<<< Updated upstream
    identifier: str = Field(..., description="NIM atau Email (email hanya untuk yang sudah diverifikasi)")
=======
    identifier: str = Field(..., description="NIM atau Email")
>>>>>>> Stashed changes
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



<<<<<<< Updated upstream
=======
class RegisterVerifyOtpInput(BaseModel):
    """Data untuk verifikasi OTP saat registrasi."""
    email: str = Field(..., description="Alamat email")
    otp: str = Field(..., min_length=6, max_length=6, description="Kode OTP 6 digit")


class ImportUserItem(BaseModel):
    """Data satu mahasiswa untuk import batch."""
    nim: str = Field(..., description="NIM")
    full_name: str = Field(..., min_length=2, description="Nama lengkap")
    faculty: str = Field(..., description="Fakultas")
    major: str = Field(..., description="Jurusan/Prodi")
    interest: Optional[str] = Field(None, description="Minat/bidang")


class ImportUsersInput(BaseModel):
    """Data untuk import batch mahasiswa."""
    users: list[ImportUserItem]
    default_password: str = Field(..., min_length=6, description="Password default untuk semua user")


class AdminCreateUserInputExtended(AdminCreateUserInput):
    """Data untuk admin membuat user baru dengan field kampus."""
    nim: Optional[str] = Field(None, description="NIM")
    faculty: Optional[str] = Field(None, description="Fakultas")
    major: Optional[str] = Field(None, description="Jurusan/Prodi")
>>>>>>> Stashed changes
