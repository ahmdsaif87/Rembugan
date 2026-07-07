from fastapi import APIRouter, Depends, HTTPException
from urllib.parse import quote
import os
from app.core.response import response_success
from app.core.security import verify_token
from app.schemas.posts import CreatePostInput, SharePostInput
from app.services.posts_service import PostsService, APP_URL

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


@router.post("/share", summary="Bagikan postingan ke teman via DM")
async def share_post(
    data: SharePostInput,
    user_token: dict = Depends(verify_token),
    svc: PostsService = Depends(),
):
    uid = user_token.get("uid")
    result = await svc.share_post(uid, data.post_id, data.post_type, data.friend_ids)
    return response_success(result, f"Berhasil dibagikan ke {result['total_sent']} teman.")


@router.get("/share-links/{post_type}/{post_id}", summary="Dapatkan link share untuk postingan")
async def get_share_links(
    post_type: str,
    post_id: str,
    user_token: dict = Depends(verify_token),
    svc: PostsService = Depends(),
):
    if post_type == "post":
        showcase = await svc.db.showcase.find_unique(where={"id": post_id})
        if not showcase:
            raise HTTPException(status_code=404, detail="Postingan tidak ditemukan.")
        preview = showcase.content[:100]
        share_link = f"{APP_URL}/s/{post_id}"
    elif post_type == "offer":
        project = await svc.db.project.find_unique(where={"id": int(post_id)})
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
        preview = project.title
        share_link = f"{APP_URL}/p/{post_id}"
    else:
        raise HTTPException(status_code=400, detail="Tipe tidak valid. Gunakan 'post' atau 'offer'.")

    share_text = f"Cek ini di Rembugan: {share_link}"
    encoded_text = quote(share_text)

    return response_success({
        "share_link": share_link,
        "whatsapp_url": f"https://api.whatsapp.com/send?text={encoded_text}",
        "telegram_url": f"https://t.me/share/url?url={quote(share_link)}&text={quote(preview)}",
    })
