from fastapi import APIRouter, Depends, HTTPException
from app.core.response import response_success
from app.core.security import verify_token
from app.services.competitions_service import CompetitionsService

router = APIRouter(prefix="/competitions", tags=["Lomba / Competitions"])


@router.get("/all", summary="Lihat Semua Lomba")
async def get_all_competitions(
    user_token: dict = Depends(verify_token),
    svc: CompetitionsService = Depends(),
):
    uid = user_token.get("uid")
    result = await svc.get_all(uid)
    return response_success(result)


@router.get("/stats", summary="Statistik Lomba")
async def get_competition_stats(
    user_token: dict = Depends(verify_token),
    svc: CompetitionsService = Depends(),
):
    return response_success(await svc.get_stats())


@router.get("/relevant", summary="Lihat Lomba Relevan dengan Skill")
async def get_relevant_competitions(
    user_token: dict = Depends(verify_token),
    svc: CompetitionsService = Depends(),
):
    uid = user_token.get("uid")
    result = await svc.get_relevant(uid)
    return response_success(result)
