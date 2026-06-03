from fastapi import APIRouter, Depends, Query, HTTPException
from prisma import Prisma
from zoneinfo import ZoneInfo

from app.core.security import verify_token
from app.core.database import get_db
from app.schemas.showcase import ShowcaseCreateInput

router = APIRouter(prefix="/showcase", tags=["Showcase / Portfolio"])


@router.post("/create", summary="Buat Postingan Showcase Baru")
async def create_showcase(
    data: ShowcaseCreateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")

    try:
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
            "message": "Showcase berhasil dipublikasikan!",
            "data": {
                "id": showcase.id,
                "content": showcase.content,
                "media_urls": showcase.media_urls,
                "tags": showcase.tags,
                "linked_project_id": showcase.linked_project_id,
                "created_at": showcase.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            },
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan saat membuat showcase: {str(e)}")


@router.get("/feed", summary="Lihat Feed Showcase Terbaru")
async def get_showcase_feed(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=50),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    skip = (page - 1) * limit

    try:
        showcases = await db.showcase.find_many(
            skip=skip,
            take=limit,
            order={"created_at": "desc"},
            include={
                "author": True,
                "project": True,
                "likes": True,
                "comments": True,
            }
        )

        result = []
        for s in showcases:
            result.append({
                "id": s.id,
                "content": s.content,
                "media_urls": s.media_urls,
                "tags": s.tags,
                "linked_project_id": s.linked_project_id,
                "linked_project_title": s.project.title if s.project else None,
                "author_name": s.author.full_name if s.author else None,
                "author_photo": s.author.photo_url if s.author else None,
                "likes_count": len(s.likes) if s.likes else 0,
                "comments_count": len(s.comments) if s.comments else 0,
                "created_at": s.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            })

        return {"status": "success", "page": page, "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan saat mengambil feed showcase: {str(e)}")

@router.get("/{showcase_id}/likes", summary="Lihat Yang Like Postingan")
async def get_showcase_likes(
    showcase_id: str,
    db: Prisma = Depends(get_db),
):
    likes = await db.showcaselike.find_many(
        where={"showcase_id": showcase_id},
        include={"user": True},
        order={"created_at": "desc"},
    )
    return {
        "status": "success",
        "data": [{"user_id": l.user_id, "full_name": l.user.full_name, "photo_url": l.user.photo_url} for l in likes]
    }

@router.get("/{showcase_id}/comments", summary="Lihat Komentar Postingan")
async def get_showcase_comments(
    showcase_id: str,
    db: Prisma = Depends(get_db),
):
    comments = await db.showcasecomment.find_many(
        where={"showcase_id": showcase_id},
        include={"user": True, "replies": {"include": {"user": True}}},
        order={"created_at": "asc"},
    )
    result = []
    for c in comments:
        result.append({
            "id": c.id,
            "content": c.content,
            "parent_id": c.parent_id,
            "user_id": c.user_id,
            "full_name": c.user.full_name,
            "photo_url": c.user.photo_url,
            "created_at": c.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            "replies": [{
                "id": r.id, "content": r.content, "user_id": r.user_id,
                "full_name": r.user.full_name, "photo_url": r.user.photo_url,
                "created_at": r.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            } for r in (c.replies or [])],
        })
    return {"status": "success", "data": result}

from pydantic import BaseModel
from datetime import datetime, timezone, timedelta

class ShowcaseUpdateInput(BaseModel):
    isi_postingan: str
    media_urls: list[str] = None
    tags: list[str] = None

@router.put("/{showcase_id}", summary="Edit Postingan Showcase")
async def edit_showcase(
    showcase_id: str,
    data: ShowcaseUpdateInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        
    if showcase.author_id != uid:
        raise HTTPException(status_code=403, detail="Anda tidak berhak mengedit showcase ini")
        
    # Cek batas waktu edit (2 jam)
    time_diff = datetime.now(timezone.utc) - showcase.created_at
    if time_diff > timedelta(hours=2):
        raise HTTPException(status_code=400, detail="Postingan tidak dapat diedit karena sudah melebihi 2 jam sejak dibuat")
        
    updated = await db.showcase.update(
        where={"id": showcase_id},
        data={
            "content": data.isi_postingan,
            "media_urls": data.media_urls or [],
            "tags": data.tags or [],
        }
    )
    return {"status": "success", "message": "Showcase berhasil diedit"}

@router.delete("/{showcase_id}", summary="Hapus Postingan Showcase")
async def delete_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        
    if showcase.author_id != uid:
        raise HTTPException(status_code=403, detail="Anda tidak berhak menghapus showcase ini")
        
    await db.showcase.delete(where={"id": showcase_id})
    return {"status": "success", "message": "Showcase berhasil dihapus"}

@router.post("/{showcase_id}/like", summary="Like Postingan Showcase")
async def like_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    
    # Cek showcase exist
    showcase = await db.showcase.find_unique(where={"id": showcase_id}, include={"author": True})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
        
    try:
        await db.showcaselike.create(
            data={
                "showcase_id": showcase_id,
                "user_id": uid,
            }
        )
        # Buat Notifikasi jika yang like bukan diri sendiri
        if showcase.author_id != uid:
            user_liker = await db.user.find_unique(where={"id": uid})
            await db.notification.create(
                data={
                    "user_id": showcase.author_id,
                    "type": "like",
                    "title": "Seseorang menyukai postingan Anda",
                    "content": f"{user_liker.full_name} menyukai postingan '{showcase.content[:20]}...'",
                    "link": f"/showcase/{showcase_id}"
                }
            )
        return {"status": "success", "message": "Berhasil menyukai showcase"}
    except Exception as e:
        # Jika sudah di-like, maka ada constraint @@unique, akan error
        return {"status": "error", "message": "Anda sudah menyukai showcase ini"}

@router.delete("/{showcase_id}/like", summary="Unlike Postingan Showcase")
async def unlike_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    uid = user_token.get("uid")
    # Cari Like
    like = await db.showcaselike.find_first(
        where={
            "showcase_id": showcase_id,
            "user_id": uid
        }
    )
    if not like:
        raise HTTPException(status_code=404, detail="Anda belum menyukai showcase ini")
        
    await db.showcaselike.delete(where={"id": like.id})
    return {"status": "success", "message": "Berhasil batal menyukai showcase"}

class CommentCreateInput(BaseModel):
    content: str
    parent_id: int = None

@router.post("/{showcase_id}/comment", summary="Komentar / Balas Komentar di Showcase")
async def comment_showcase(
    showcase_id: str,
    data: CommentCreateInput,
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
            "parent_id": data.parent_id
        }
    )
    
    # Buat Notifikasi
    user_commenter = await db.user.find_unique(where={"id": uid})
    if showcase.author_id != uid:
        await db.notification.create(
            data={
                "user_id": showcase.author_id,
                "type": "comment",
                "title": "Seseorang mengomentari postingan Anda",
                "content": f"{user_commenter.full_name} mengomentari postingan Anda: '{data.content[:30]}'",
                "link": f"/showcase/{showcase_id}"
            }
        )
        
    # Jika ini balasan ke komentar lain, beritahu author komentar tersebut
    if data.parent_id:
        parent_comment = await db.showcasecomment.find_unique(where={"id": data.parent_id})
        if parent_comment and parent_comment.user_id != uid:
            await db.notification.create(
                data={
                    "user_id": parent_comment.user_id,
                    "type": "comment",
                    "title": "Seseorang membalas komentar Anda",
                    "content": f"{user_commenter.full_name} membalas komentar Anda.",
                    "link": f"/showcase/{showcase_id}"
                }
            )

    return {"status": "success", "message": "Berhasil mengirim komentar", "data": {"comment_id": comment.id}}
