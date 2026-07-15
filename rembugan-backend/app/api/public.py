from fastapi import APIRouter, Depends
from app.core.response import response_success
from app.services.admin_service import AdminService

router = APIRouter(tags=["Public"])


@router.get("/privacy-policy", summary="Get Privacy Policy (Public)")
async def get_privacy_policy(
    svc: AdminService = Depends(),
):
    content = await svc.get_privacy_policy()
    return response_success({"content": content})
