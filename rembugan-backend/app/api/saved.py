from fastapi import APIRouter, Depends, HTTPException, Query
from prisma import Prisma

from app.core.database import get_db
from app.core.security import verify_token

router = APIRouter(prefix="/saved", tags=["9. Saved Items"])


@router.get("/", summary="Lihat Semua Item yang Disimpan")
async def get_saved_items(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil daftar semua item yang disimpan oleh user."""
    uid = user_token.get("uid")

    saved = await db.saveditem.find_many(
        where={"user_id": uid},
        include={
            "project": {"include": {"owner": True, "members": True}},
            "showcase": {"include": {"author": True}},
        },
        order={"created_at": "desc"},
        skip=(page - 1) * limit,
        take=limit,
    )

    result = []
    for item in saved:
        entry = {
            "id": item.id,
            "type": "project" if item.project else "showcase",
            "created_at": item.created_at.isoformat(),
        }
        if item.project:
            entry["project"] = {
                "id": item.project.id,
                "title": item.project.title,
                "description": item.project.description,
                "required_skills": item.project.required_skills,
                "status": item.project.status,
                "owner_name": item.project.owner.full_name if item.project.owner else None,
                "member_count": len(item.project.members) if item.project.members else 0,
            }
        if item.showcase:
            entry["showcase"] = {
                "id": item.showcase.id,
                "content": item.showcase.content,
                "media_urls": item.showcase.media_urls,
                "author_name": item.showcase.author.full_name if item.showcase.author else None,
            }
        result.append(entry)

    return {"status": "success", "data": result}


@router.post("/project/{project_id}", summary="Simpan Project")
async def save_project(
    project_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Simpan project ke daftar saved."""
    uid = user_token.get("uid")

    project = await db.project.find_unique(where={"id": project_id})
    if not project:
        raise HTTPException(status_code=404, detail="Project tidak ditemukan")

    existing = await db.saveditem.find_first(
        where={"user_id": uid, "project_id": project_id}
    )
    if existing:
        raise HTTPException(status_code=400, detail="Project sudah disimpan")

    saved = await db.saveditem.create(
        data={"user_id": uid, "project_id": project_id}
    )

    return {
        "status": "success",
        "message": "Project berhasil disimpan!",
        "data": {"id": saved.id, "type": "project"},
    }


@router.post("/showcase/{showcase_id}", summary="Simpan Showcase")
async def save_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Simpan showcase ke daftar saved."""
    uid = user_token.get("uid")

    showcase = await db.showcase.find_unique(where={"id": showcase_id})
    if not showcase:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")

    existing = await db.saveditem.find_first(
        where={"user_id": uid, "showcase_id": showcase_id}
    )
    if existing:
        raise HTTPException(status_code=400, detail="Showcase sudah disimpan")

    saved = await db.saveditem.create(
        data={"user_id": uid, "showcase_id": showcase_id}
    )

    return {
        "status": "success",
        "message": "Showcase berhasil disimpan!",
        "data": {"id": saved.id, "type": "showcase"},
    }


@router.get("/check/{showcase_id}", summary="Cek Status Saved Showcase")
async def check_saved_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Cek apakah showcase sudah disimpan oleh user."""
    uid = user_token.get("uid")
    saved = await db.saveditem.find_first(
        where={"user_id": uid, "showcase_id": showcase_id}
    )
    return {
        "status": "success",
        "data": {"is_saved": saved is not None, "saved_id": saved.id if saved else None},
    }


@router.delete("/{item_id}", summary="Hapus Item yang Disimpan")
async def remove_saved_item(
    item_id: int,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Hapus item dari daftar saved berdasarkan saved_item_id."""
    uid = user_token.get("uid")

    saved = await db.saveditem.find_first(where={"id": item_id, "user_id": uid})
    if not saved:
        raise HTTPException(status_code=404, detail="Item tidak ditemukan")

    await db.saveditem.delete(where={"id": item_id})

    return {"status": "success", "message": "Item berhasil dihapus dari saved"}


@router.delete("/by-showcase/{showcase_id}", summary="Hapus Saved Showcase")
async def remove_saved_showcase(
    showcase_id: str,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Hapus showcase dari daftar saved berdasarkan showcase_id."""
    uid = user_token.get("uid")
    saved = await db.saveditem.find_first(
        where={"user_id": uid, "showcase_id": showcase_id}
    )
    if not saved:
        raise HTTPException(status_code=404, detail="Showcase tidak ditemukan di saved")

    await db.saveditem.delete(where={"id": saved.id})
    return {"status": "success", "message": "Showcase berhasil dihapus dari saved"}
