from fastapi import APIRouter, Depends
from app.core.response import response_success
from app.core.security import verify_token
from app.schemas.posts import CreatePostInput
from app.services.posts_service import PostsService

router = APIRouter(prefix="/posts", tags=["Posts & Offers"])


@router.post("/create", summary="Buat Postingan atau Tawaran")
async def create_post(
    data: CreatePostInput,
    user_token: dict = Depends(verify_token),
    svc: PostsService = Depends(),
):
    uid = user_token.get("uid")
    result = await svc.create_post(uid, data.model_dump())

    if result["type"] == "post":
        message = "Postingan berhasil dibuat!"
    else:
        message = f"Tawaran '{result['title']}' berhasil dibuat!"

    return response_success(result, message)
