from fastapi import APIRouter, Depends, Query
from app.core.response import response_success
from app.core.security import verify_token
from app.services.profile_service_sql import ProfileServiceSQL

router = APIRouter(prefix="/v2/profile", tags=["Profile SQL (POC)"])


@router.get("/search")
async def search_users(
    q: str = Query(..., min_length=1),
    svc: ProfileServiceSQL = Depends(),
):
    data = await svc.search(q)
    return response_success(data)
