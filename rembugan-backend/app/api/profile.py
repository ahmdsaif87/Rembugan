from typing import Optional
from fastapi import APIRouter, Depends, Query
from app.core.response import response_success
from app.core.security import verify_token, verify_token_optional
from app.schemas.profile import SettingsUpdateInput
from app.services.profile_service import ProfileService

router = APIRouter(prefix="/profile", tags=["Profil User"])


@router.get("/recommended-for-project/{project_id}", summary="Rekomendasi User untuk Offering Proyek")
async def get_recommended_for_project(
    project_id: int,
    limit: int = Query(10, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    svc: ProfileService = Depends(),
):
    result = await svc.get_recommended_for_project(user_token["uid"], project_id, limit)
    return response_success(result)


@router.patch("/settings", summary="Update Settings Profil")
async def update_settings(
    data: SettingsUpdateInput,
    user_token: dict = Depends(verify_token),
    svc: ProfileService = Depends(),
):
    result = await svc.update_settings(user_token["uid"], data)
    return response_success(result, "Settings berhasil diupdate!")


@router.get("/recommended", summary="Rekomendasi User untuk Dikenal")
async def get_recommended_users(
    limit: int = Query(10, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    svc: ProfileService = Depends(),
):
    result = await svc.get_recommended(user_token["uid"], limit)
    return response_success(result)


@router.get("/search", summary="Cari User Berdasarkan Nama atau NIM")
async def search_users(
    q: str = Query(..., min_length=1),
    user_token: dict = Depends(verify_token),
    svc: ProfileService = Depends(),
):
    result = await svc.search(q)
    return response_success(result)


@router.get("/me", summary="Lihat Profil Saya Sendiri")
async def get_my_profile(
    user_token: dict = Depends(verify_token),
    svc: ProfileService = Depends(),
):
    result = await svc.get_profile(user_token["uid"], user_token)
    return response_success(result)


@router.get("/{user_id}", summary="Lihat Profil Pengguna Lain")
async def get_profile_route(
    user_id: str,
    svc: ProfileService = Depends(),
    user_token: dict | None = Depends(verify_token_optional),
):
    result = await svc.get_profile(user_id, user_token)
    return response_success(result)
