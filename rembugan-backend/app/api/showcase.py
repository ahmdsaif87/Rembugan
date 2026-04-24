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
                "created_at": s.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
            })

        return {"status": "success", "page": page, "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan saat mengambil feed showcase: {str(e)}")
