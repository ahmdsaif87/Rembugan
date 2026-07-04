from fastapi import APIRouter, Depends, Query, HTTPException
from app.core.response import response_success, response_paginated
from app.core.security import verify_token
from app.schemas.showcase import ShowcaseCreateInput, CommentCreateInput
from app.services.showcase_service import ShowcaseService

router = APIRouter(prefix="/showcase", tags=["4. Showcase & Portofolio"])


@router.post("/create", summary="Buat Postingan Showcase Baru")
async def create_showcase(
    data: ShowcaseCreateInput,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    showcase = await svc.create(
        user_token["uid"], data.isi_postingan,
        data.media_urls or [], data.tags or [],
        data.linked_project_id,
    )
    return response_success({"id": showcase.id, "content": showcase.content[:50]}, "Showcase berhasil dibuat!")


@router.get("/", summary="Lihat Semua Showcase (Feed) — cosine-based")
async def get_all_showcases(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=50),
    tab: str = Query("for-you", regex="^(for-you|following)$"),
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    if tab == "following":
        data, total = await svc.get_following_feed(user_token["uid"], page, limit)
    else:
        data, total = await svc.get_feed(user_token["uid"], page, limit)
    return response_paginated(data, total, page, limit)


@router.get("/my", summary="Showcase Saya Sendiri")
async def get_my_showcases(
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    data = await svc.get_mine(user_token["uid"])
    return response_success(data)


@router.get("/{showcase_id}", summary="Detail Showcase")
async def get_showcase_detail(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    data = await svc.get_detail(showcase_id, user_token["uid"])
    return response_success(data)


@router.post("/{showcase_id}/like", summary="Like Postingan Showcase")
async def like_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    await svc.like(showcase_id, user_token["uid"])
    return response_success(message="Berhasil menyukai showcase")


@router.delete("/{showcase_id}/like", summary="Unlike Postingan Showcase")
async def unlike_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    await svc.unlike(showcase_id, user_token["uid"])
    return response_success(message="Berhasil batal menyukai showcase")


@router.post("/{showcase_id}/comment", summary="Komentar / Balas Komentar di Showcase")
async def comment_showcase(
    showcase_id: str,
    data: CommentCreateInput,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    comment = await svc.comment(showcase_id, user_token["uid"], data.content, data.parent_id)
    return response_success({"comment_id": comment.id}, "Berhasil mengirim komentar")


@router.get("/{showcase_id}/share-link", summary="Share Link Showcase")
async def get_showcase_share_link(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    link = await svc.get_share_link(showcase_id)
    return response_success({"link": link, "type": "showcase", "showcase_id": showcase_id})


@router.post("/{showcase_id}/share/{receiver_id}", summary="Share Showcase ke User")
async def share_showcase_to_user(
    showcase_id: str,
    receiver_id: str,
    user_token: dict = Depends(verify_token),
    svc: ShowcaseService = Depends(),
):
    link = await svc.share_to_user(showcase_id, user_token["uid"], receiver_id)
    return response_success({"link": link}, "Showcase berhasil dibagikan!")
