from fastapi import APIRouter, Depends
from app.core.response import response_success
from app.core.security import verify_token
from app.services.fyp_service import FypService

router = APIRouter(prefix="/fyp", tags=["Halaman Beranda (FYP)"])


@router.get("/", summary="Ambil Data Personalized FYP")
async def get_fyp(
    user_token: dict = Depends(verify_token),
    svc: FypService = Depends(),
):
    result = await svc.get_fyp(user_token.get("uid"))
    return response_success(result)
