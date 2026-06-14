import os
from fastapi import APIRouter, Depends, Query, HTTPException, BackgroundTasks
from prisma import Prisma
from zoneinfo import ZoneInfo
from app.core.dates import tz_iso

from app.core.security import verify_token
from app.core.database import get_db
from app.core.constants import NOTIF_LIKE, NOTIF_COMMENT, NOTIF_CHAT
from app.schemas.showcase import ShowcaseCreateInput, CommentCreateInput
from app.services.notification import notify

router = APIRouter(prefix="/showcase", tags=["4. Showcase & Portofolio"])


@router.post("/create", summary="Buat Postingan Showcase Baru")
async def create_showcase(
    data: ShowcaseCreateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    showcase = await db.showcase.create(
        data={
            "author_id": uid,
            "content": data.isi_postingan,
            "media_urls": data.media_urls or [],
            "tags": data.tags or [],
            "linked_project_id": data.linked_project_id,
        }
    )
    return {
        "status": "success",
        "message": "Showcase berhasil dibuat!",
        "data": {
            "id": showcase.id,
            "content": showcase.content[:50],
        },
    }


@router.get("/", summary="Lihat Semua Showcase (Feed)")
async def get_all_showcases(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    total = await db.showcase.count()
    showcases = await db.showcase.find_many(
        order={"created_at": "desc"},
        skip=(page - 1) * limit,
        take=limit,
        include={
            "author": True,
            "likes": True,
            "comments": True,
        }
    )

    data = []
    for s in showcases:
        liked = any(l.user_id == uid for l in s.likes)
        data.append({
            "id": s.id,
            "author_id": s.author_id,
            "author_name": s.author.full_name if s.author else None,
            "author_photo": s.author.photo_url if s.author else None,
            "content": s.content,
            "media_urls": s.media_urls,
            "tags": s.tags,
            "likes_count": len(s.likes),
            "comments_count": len(s.comments),
            "liked_by_me": liked,
            "created_at": tz_iso(s.created_at),
        })

    return {
        "status": "success",
        "data": data,
        "page": page,
        "limit": limit,
        "total": total,
    }


@router.get("/my", summary="Showcase Saya Sendiri")
async def get_my_showcases(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    showcases = await db.showcase.find_many(
        where={"author_id": uid},
        order={"created_at": "desc"},
        include={"likes": True, "comments": True},
    )
    data = []
    for s in showcases:
        data.append({
            "id": s.id,
            "content": s.content,
            "media_urls": s.media_urls,
            "tags": s.tags,
            "likes_count": len(s.likes),
            "comments_count": len(s.comments),
            "created_at": tz_iso(s.created_at),
        })
    return {"status": "success", "data": data}


@router.get("/{showcase_id}", summary="Detail Showcase")
async def get_showcase_detail(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    showcase = await db.showcase.find_unique(
        where={"id": showcase_id},
        include={
            "author": True,
            "likes": {"include": {"user": True}},
            "comments": {
                "include": {"user": True, "replies": {"include": {"user": True}}},
                "order": {"created_at": "asc"},
            },
        }
    )
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

    liked = any(l.user_id == uid for l in showcase.likes)

    comments_data = []
    for c in showcase.comments:
        replies = []
        for r in c.replies:
            replies.append({
                "id": r.id,
                "user_id": r.user_id,
                "full_name": r.user.full_name if r.user else None,
                "content": r.content,
                "created_at": r.created_at.isoformat(),
            })
        comments_data.append({
            "id": c.id,
            "user_id": c.user_id,
            "full_name": c.user.full_name if c.user else None,
            "content": c.content,
            "replies": replies,
            "created_at": c.created_at.isoformat(),
        })

    return {
        "status": "success",
        "data": {
            "id": showcase.id,
            "author_id": showcase.author_id,
            "author_name": showcase.author.full_name if showcase.author else None,
            "author_photo": showcase.author.photo_url if showcase.author else None,
            "content": showcase.content,
            "media_urls": showcase.media_urls,
            "tags": showcase.tags,
            "likes_count": len(showcase.likes),
            "liked_by_me": liked,
            "comments": comments_data,
            "created_at": tz_iso(showcase.created_at),
        },
    }


@router.post("/{showcase_id}/like", summary="Like Postingan Showcase")
async def like_showcase(
    showcase_id: str,
    background_tasks: BackgroundTasks,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")

    showcase = await db.showcase.find_unique(where={"id": showcase_id}, include={"author": True})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

    try:
        await db.showcaselike.create(
            data={"showcase_id": showcase_id, "user_id": uid}
        )
        if showcase.author_id != uid:
            user_liker = await db.user.find_unique(where={"id": uid})
            background_tasks.add_task(
                notify, db, showcase.author_id, NOTIF_LIKE,
                "Seseorang menyukai postingan Anda",
                f"{user_liker.full_name} menyukai postingan '{showcase.content[:20]}...'",
                f"/showcase/{showcase_id}",
            )
        return {"status": "success", "message": "Berhasil menyukai showcase"}
    except Exception:
        return {"status": "error", "message": "Anda sudah menyukai showcase ini"}


@router.delete("/{showcase_id}/like", summary="Unlike Postingan Showcase")
async def unlike_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    like = await db.showcaselike.find_first(
        where={"showcase_id": showcase_id, "user_id": uid}
    )
    if not like:
        raise HTTPException(status_code=404, detail="Anda belum menyukai showcase ini")

    await db.showcaselike.delete(where={"id": like.id})
    return {"status": "success", "message": "Berhasil batal menyukai showcase"}


@router.post("/{showcase_id}/comment", summary="Komentar / Balas Komentar di Showcase")
async def comment_showcase(
    showcase_id: str,
    data: CommentCreateInput,
    background_tasks: BackgroundTasks,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")

    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

    comment = await db.showcasecomment.create(
        data={
            "showcase_id": showcase_id,
            "user_id": uid,
            "content": data.content,
            "parent_id": data.parent_id,
        }
    )

    user_commenter = await db.user.find_unique(where={"id": uid})

    if showcase.author_id != uid:
        background_tasks.add_task(
            notify, db, showcase.author_id, NOTIF_COMMENT,
            "Seseorang mengomentari postingan Anda",
            f"{user_commenter.full_name} mengomentari: '{data.content[:30]}'",
            f"/showcase/{showcase_id}",
        )

    if data.parent_id:
        parent_comment = await db.showcasecomment.find_unique(where={"id": data.parent_id})
        if parent_comment and parent_comment.user_id != uid:
            background_tasks.add_task(
                notify, db, parent_comment.user_id, NOTIF_COMMENT,
                "Seseorang membalas komentar Anda",
                f"{user_commenter.full_name} membalas komentar Anda.",
                f"/showcase/{showcase_id}",
            )

    return {"status": "success", "message": "Berhasil mengirim komentar", "data": {"comment_id": comment.id}}


@router.get("/{showcase_id}/share-link", summary="Share Link Showcase")
async def get_showcase_share_link(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

    APP_URL = os.getenv("APP_URL", "https://rembugan.app")
    return {
        "status": "success",
        "data": {
            "link": f"{APP_URL}/s/{showcase_id}",
            "type": "showcase",
            "showcase_id": showcase_id,
        }
    }


@router.post("/{showcase_id}/share/{receiver_id}", summary="Share Showcase ke User")
async def share_showcase_to_user(
    showcase_id: str,
    receiver_id: str,
    background_tasks: BackgroundTasks,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")

    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

    receiver = await db.user.find_unique(where={"id": receiver_id})
    if not receiver:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")

    APP_URL = os.getenv("APP_URL", "https://rembugan.app")
    link = f"{APP_URL}/s/{showcase_id}"
    sender = await db.user.find_unique(where={"id": uid})

    content = f"Membagikan postingan: {link}"
    if sender:
        content = f"{sender.full_name} membagikan postingan: {link}"

    await db.message.create(
        data={"content": content, "sender_id": uid, "receiver_id": receiver_id}
    )

    background_tasks.add_task(
        notify, db, receiver_id, NOTIF_CHAT,
        "Postingan dibagikan ke Anda",
        content[:60],
        f"/chat/dm_{uid}_{receiver_id}",
    )

    return {
        "status": "success",
        "message": "Showcase berhasil dibagikan!",
        "data": {"link": link},
    }
