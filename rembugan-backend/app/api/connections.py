from fastapi import APIRouter, Depends, Query
from app.core.response import response_success
from app.core.security import verify_token
from app.services.connections_service import ConnectionsService

router = APIRouter(prefix="/connections", tags=["Koneksi (Teman)"])


@router.get("/", summary="Lihat Koneksi Saya (yang sudah accepted)")
async def get_my_connections(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.get_my_connections(user_token["uid"], skip=(page - 1) * limit, limit=limit)
    return response_success(result)


@router.get("/incoming", summary="Lihat Permintaan Koneksi Masuk")
async def get_incoming_requests(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.get_incoming(user_token["uid"], skip=(page - 1) * limit, limit=limit)
    return response_success(result)


@router.get("/sent", summary="Lihat Permintaan Koneksi Terkirim")
async def get_sent_requests(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.get_sent(user_token["uid"], skip=(page - 1) * limit, limit=limit)
    return response_success(result)


@router.get("/{user_id}", summary="Lihat Koneksi User Lain")
async def get_user_connections(
    user_id: str,
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.get_user_connections(user_token["uid"], user_id)
    return response_success(result)


@router.post("/send/{receiver_id}", summary="Kirim Permintaan Koneksi")
async def send_connection_request(
    receiver_id: str,
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.send_request(user_token["uid"], receiver_id)
    return response_success(result, "Permintaan terkirim")


@router.put("/accept/{connection_id}", summary="Terima Permintaan Koneksi")
async def accept_connection(
    connection_id: int,
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.accept_request(connection_id, user_token["uid"])
    return response_success(result, "Koneksi diterima")


@router.put("/reject/{connection_id}", summary="Tolak Permintaan Koneksi")
async def reject_connection(
    connection_id: int,
    user_token: dict = Depends(verify_token),
    svc: ConnectionsService = Depends(),
):
    result = await svc.reject_request(connection_id, user_token["uid"])
    return response_success(result, "Koneksi ditolak")
