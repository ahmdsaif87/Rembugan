from fastapi import APIRouter, Depends, Request
from app.core.response import response_success
from app.core.rate_limit import limiter
from app.core.security import verify_token
from app.schemas.auth import (
    RegisterInput, LoginInput, AdminLoginInput,
    SendOtpInput, VerifyOtpInput, ForgotPasswordSendOtpInput,
    ForgotPasswordResetInput, RegisterVerifyOtpInput,
)
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["0. Authentication"])


@router.post("/register", summary="Register User Baru (NIM + Password)")
@limiter.limit("5/minute")
async def register(request: Request, data: RegisterInput, svc: AuthService = Depends()):
    result = await svc.register(data.nim, data.password, data.full_name, data.major)
    return response_success(result, f"Registrasi berhasil! Selamat datang, {result['full_name']}.")


@router.post("/register/verify-otp", summary="Verifikasi OTP Registrasi")
@limiter.limit("5/minute")
async def register_verify_otp(request: Request, data: RegisterVerifyOtpInput, svc: AuthService = Depends()):
    await svc.register_verify_otp(data.email, data.otp)
    return response_success(message="Email berhasil diverifikasi! Silakan login.")


@router.post("/login", summary="Login via NIM atau Email + Password")
@limiter.limit("10/minute")
async def login(request: Request, data: LoginInput, svc: AuthService = Depends()):
    result = await svc.login(data.identifier, data.password)
    return response_success(result, f"Login berhasil! Halo, {result['full_name']}.")


@router.post("/admin-login", summary="Login Admin Dashboard")
@limiter.limit("10/minute")
async def admin_login(request: Request, data: AdminLoginInput, svc: AuthService = Depends()):
    result = await svc.admin_login(data.email, data.password)
    return response_success(result, "Login admin berhasil!")


@router.post("/email/send-otp", summary="Kirim OTP Verifikasi Email")
@limiter.limit("3/minute")
async def send_otp(request: Request, data: SendOtpInput, svc: AuthService = Depends(), user_token: dict = Depends(verify_token)):
    email = await svc.send_otp(user_token["uid"], data.email)
    return response_success(message=f"Kode OTP berhasil dikirim ke {email}.")


@router.post("/email/verify-otp", summary="Verifikasi OTP Email")
@limiter.limit("5/minute")
async def verify_otp(request: Request, data: VerifyOtpInput, svc: AuthService = Depends(), user_token: dict = Depends(verify_token)):
    result = await svc.verify_otp(user_token["uid"], data.email, data.otp)
    return response_success(result, "Email berhasil diverifikasi! Sekarang kamu bisa login menggunakan email.")


@router.post("/forgot-password/send-otp", summary="Kirim OTP Reset Password via NIM")
@limiter.limit("3/minute")
async def forgot_password_send_otp(request: Request, data: ForgotPasswordSendOtpInput, svc: AuthService = Depends()):
    await svc.forgot_password_send_otp(data.nim)
    return response_success(message="Kode OTP berhasil dikirim ke email terdaftar.")


@router.post("/forgot-password/reset", summary="Reset Password via OTP")
@limiter.limit("5/minute")
async def forgot_password_reset(request: Request, data: ForgotPasswordResetInput, svc: AuthService = Depends()):
    await svc.forgot_password_reset(data.nim, data.otp, data.new_password)
    return response_success(message="Password berhasil direset. Silakan login dengan password baru.")


@router.get("/me", summary="Cek Data User yang Sedang Login")
async def get_current_user(svc: AuthService = Depends(), user_token: dict = Depends(verify_token)):
    result = await svc.get_me(user_token["uid"])
    return response_success(result)
