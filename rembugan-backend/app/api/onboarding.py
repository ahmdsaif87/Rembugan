from fastapi import APIRouter, UploadFile, File, Depends
from app.core.response import response_success
from app.core.security import verify_token
from app.schemas.user import UserProfileInput
from app.services.onboarding_service import OnboardingService

router = APIRouter(prefix="/onboarding", tags=["1. AI & Onboarding"])


@router.post("/extract-cv", summary="Ekstrak Data CV (OCR + AI)")
async def extract_cv_data(
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
    service: OnboardingService = Depends(OnboardingService),
):
    data = await service.extract_cv(file)
    return response_success(data, "Analisis CV selesai!")


@router.put("/save-profile", summary="Update Profil User")
async def save_user_profile(
    data: UserProfileInput,
    user_token: dict = Depends(verify_token),
    service: OnboardingService = Depends(OnboardingService),
):
    uid = user_token.get("uid")
    result = await service.save_profile(uid, data)
    return response_success(result, "Profil berhasil diupdate!")


@router.get("/profile", summary="Ambil Profil User yang Login")
async def get_my_profile(
    user_token: dict = Depends(verify_token),
    service: OnboardingService = Depends(OnboardingService),
):
    uid = user_token.get("uid")
    data = await service.get_my_profile(uid)
    return response_success(data)
