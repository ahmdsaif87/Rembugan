from fastapi import APIRouter, Depends, Query
from app.core.response import response_success
from app.core.security import verify_token
from app.services.saved_service import SavedService

router = APIRouter(prefix="/saved", tags=["9. Saved Items"])


@router.get("/", summary="Lihat Semua Item yang Disimpan")
async def get_saved_items(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: SavedService = Depends(),
):
    data, total = await svc.list_saved(user_token["uid"], page, limit)
    return response_success({"data": data, "total": total, "page": page, "limit": limit})


@router.post("/project/{project_id}", summary="Simpan Project")
async def save_project(
    project_id: int,
    user_token: dict = Depends(verify_token),
    svc: SavedService = Depends(),
):
    result = await svc.save_project(user_token["uid"], project_id)
    return response_success(result, "Project berhasil disimpan!")


@router.post("/showcase/{showcase_id}", summary="Simpan Showcase")
async def save_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: SavedService = Depends(),
):
    result = await svc.save_showcase(user_token["uid"], showcase_id)
    return response_success(result, "Showcase berhasil disimpan!")


@router.get("/check/{showcase_id}", summary="Cek Status Saved Showcase")
async def check_saved_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: SavedService = Depends(),
):
    result = await svc.check_saved(user_token["uid"], showcase_id=showcase_id)
    return response_success(result)


@router.delete("/{item_id}", summary="Hapus Item yang Disimpan")
async def remove_saved_item(
    item_id: int,
    user_token: dict = Depends(verify_token),
    svc: SavedService = Depends(),
):
    await svc.unsave(item_id, user_token["uid"])
    return response_success(message="Item berhasil dihapus dari saved")


@router.delete("/by-showcase/{showcase_id}", summary="Hapus Saved Showcase")
async def remove_saved_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: SavedService = Depends(),
):
    await svc.unsave_showcase(showcase_id, user_token["uid"])
    return response_success(message="Showcase berhasil dihapus dari saved")
