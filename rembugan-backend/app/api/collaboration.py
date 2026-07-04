from fastapi import APIRouter, Depends
from app.core.response import response_success
from app.core.security import verify_token
from app.schemas.collaboration import ApplyInput, RespondInput
from app.services.collaboration_service import CollaborationService

router = APIRouter(prefix="/collaboration", tags=["3. Kolaborasi"])


@router.post("/{project_id}/apply", summary="Kirim Lamaran ke Proyek")
async def apply_to_project(
    project_id: int,
    data: ApplyInput,
    user_token: dict = Depends(verify_token),
    svc: CollaborationService = Depends(),
):
    result = await svc.apply(project_id, user_token["uid"], data.message, data.contact_info)
    return response_success(result, "Lamaran berhasil dikirim!")


@router.get("/applications/{project_id}", summary="Lihat Semua Lamaran di Proyek")
async def get_project_applications(
    project_id: int,
    user_token: dict = Depends(verify_token),
    svc: CollaborationService = Depends(),
):
    result = await svc.list_applications(project_id, user_token["uid"])
    return response_success(result)


@router.put("/applications/{application_id}/respond", summary="Accept/Reject Lamaran")
async def respond_to_application(
    application_id: int,
    data: RespondInput,
    user_token: dict = Depends(verify_token),
    svc: CollaborationService = Depends(),
):
    result = await svc.respond_to_application(application_id, user_token["uid"], data.status, data.role)
    return response_success(result, f"Lamaran berhasil di-{data.status}.")
