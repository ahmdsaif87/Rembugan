from fastapi import APIRouter, Depends
from app.core.response import response_success
from app.core.security import verify_token
from app.services.qr_service import QrService

router = APIRouter(prefix="/qr", tags=["8. QR Code"])


@router.get("/profile")
async def get_profile_qr(
    user_token: dict = Depends(verify_token),
    service: QrService = Depends(QrService),
):
    uid = user_token.get("uid")
    return response_success(service.get_profile_qr(uid))


@router.get("/profile/{user_id}")
async def get_other_profile_qr(
    user_id: str,
    service: QrService = Depends(QrService),
):
    data = await service.get_other_profile_qr(user_id)
    return response_success(data)


@router.get("/showcase/{showcase_id}", summary="QR Link Showcase")
async def get_showcase_qr(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    service: QrService = Depends(QrService),
):
    data = await service.get_showcase_qr(showcase_id)
    return response_success(data)


@router.post("/project/{project_id}/invite")
async def create_project_invite(
    project_id: int,
    user_token: dict = Depends(verify_token),
    service: QrService = Depends(QrService),
):
    uid = user_token.get("uid")
    role = user_token.get("role")
    data = await service.create_project_invite(project_id, uid, role)
    return response_success(data)


@router.get("/project/join/{token}")
async def verify_invite_token(
    token: str,
    service: QrService = Depends(QrService),
):
    data = await service.verify_invite_token(token)
    return response_success(data)


@router.post("/project/join/{token}")
async def join_project_via_invite(
    token: str,
    user_token: dict = Depends(verify_token),
    service: QrService = Depends(QrService),
):
    uid = user_token.get("uid")
    data = await service.join_project_via_invite(token, uid)
    return response_success(data, "Berhasil join project!")
