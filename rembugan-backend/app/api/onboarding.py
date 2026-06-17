import asyncio
from datetime import datetime
from typing import List
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from dateutil import parser as dateparser
from prisma import Prisma, Json
from app.core.dates import tz_iso

from app.core.security import verify_token
from app.core.database import get_db
from app.schemas.user import UserProfileInput, ExperienceInput
from app.services.ai_vision import extract_photo_from_pdf
from app.services.ai_nlp import extract_text_from_pdf, process_resume_with_ai
from app.services.storage import upload_image_to_cloudinary

router = APIRouter(prefix="/onboarding", tags=["1. AI & Onboarding"])


def _format_nama(nama: str) -> str:
    """Ubah nama kapital jadi title case."""
    if not nama or nama == "Tidak Terdeteksi":
        return nama
    return nama.title()


def _parse_duration(duration: str) -> tuple[datetime, datetime | None]:
    """Parse string durasi (e.g. 'Feb 2025 - Jun 2025') menjadi start/end date."""
    if not duration:
        now = datetime.now()
        return now, None

    parts = [p.strip() for p in duration.replace("–", "-").replace("—", "-").split("-") if p.strip()]

    try:
        start = dateparser.parse(parts[0], default=datetime(2000, 1, 1))
        if len(parts) > 1 and parts[1].lower() not in ("present", "sekarang", "now", ""):
            end = dateparser.parse(parts[1], default=datetime.now())
        else:
            end = None
        return start, end
    except (ValueError, TypeError):
        return datetime.now(), None


@router.post("/extract-cv", summary="Ekstrak Data CV (OCR + AI)")
async def extract_cv_data(
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
):
    """
    Upload file PDF CV, lalu:
    1. Ekstrak foto profil dari PDF
    2. OCR seluruh teks dari PDF
    3. AI (Groq) merapikan teks menjadi data terstruktur (nama, skills, bio)
    """
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Format file harus PDF!")

    file_bytes = await file.read()

    loop = asyncio.get_running_loop()

    # 1. Ekstrak foto dari PDF (blocking → run_in_executor)
    photo_url = None
    try:
        photo_bytes = await loop.run_in_executor(None, extract_photo_from_pdf, file_bytes)
        if photo_bytes:
            photo_url = await upload_image_to_cloudinary(photo_bytes)
    except Exception:
        pass

    # 2. Ekstrak teks mentah via OCR (blocking → run_in_executor)
    raw_text = await loop.run_in_executor(None, extract_text_from_pdf, file_bytes)

    # 3. Rapikan teks menjadi JSON pakai AI (blocking → run_in_executor)
    ai_result = await loop.run_in_executor(None, process_resume_with_ai, raw_text)

    return {
        "status": "success",
        "message": "Analisis CV selesai!",
        "data": {
            "photo_url": photo_url,
            "nama": _format_nama(ai_result.get("nama", "Tidak Terdeteksi")),
            "skills_terdeteksi": ai_result.get("skills", []),
            "bio_suggestion": ai_result.get("bio_suggestion", ""),
            "experiences": ai_result.get("experiences", []),
        }
    }


@router.put("/save-profile", summary="Update Profil User")
async def save_user_profile(
    data: UserProfileInput,
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """
    Update profil user yang sudah terdaftar (via /auth/register).
    Menyimpan bio, photo, skills, dan social_links.
    """
    uid = user_token.get("uid")

    # Pastikan user sudah terdaftar
    existing = await db.user.find_unique(where={"id": uid})
    if not existing:
        raise HTTPException(status_code=404, detail="User belum terdaftar. Silakan register dulu via /auth/register.")

    # 1. Update profil user (hanya field yang tidak null)
    update_data: dict[str, str | bool | Json] = {
        "is_onboarded": True,
    }
    if data.full_name is not None:
        update_data["full_name"] = data.full_name
    if data.bio is not None:
        update_data["bio"] = data.bio
    if data.photo_url is not None:
        update_data["photo_url"] = data.photo_url

    if data.social_links:
        update_data["social_links"] = Json(data.social_links)

    user = await db.user.update(
        where={"id": uid},
        data=update_data,
    )

    # 2. Sinkronisasi Skills (batch — avoid N×2 Prisma round trips)
    await db.userskill.delete_many(where={"user_id": uid})

    if data.skills:
        existing_skills = await db.skill.find_many(
            where={"name": {"in": data.skills}}
        )
        name_to_id = {s.name: s.id for s in existing_skills}

        new_names = [n for n in data.skills if n not in name_to_id]
        if new_names:
            await db.skill.create_many(data=[{"name": n} for n in new_names])
            new_skills = await db.skill.find_many(
                where={"name": {"in": new_names}}
            )
            for s in new_skills:
                name_to_id[s.name] = s.id

        await db.userskill.create_many(
            data=[{"user_id": uid, "skill_id": name_to_id[n]} for n in data.skills]
        )

    # 3. Simpan Experiences
    await db.experience.delete_many(where={"user_id": uid})

    for exp in data.experiences:
        start_date, end_date = _parse_duration(exp.duration)
        await db.experience.create(data={
            "user_id": uid,
            "title": exp.title,
            "company": exp.organization,
            "description": exp.description,
            "start_date": start_date,
            "end_date": end_date,
        })

    return {
        "status": "success",
        "message": "Profil berhasil diupdate!",
        "data": {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "skills": data.skills,
        },
    }


@router.get("/profile", summary="Ambil Profil User yang Login")
async def get_my_profile(
    user_token: dict = Depends(verify_token),
    db: Prisma = Depends(get_db),
):
    """Ambil data profil user yang sedang login beserta skills-nya."""
    uid = user_token.get("uid")

    user = await db.user.find_unique(
        where={"id": uid},
        include={"skills": {"include": {"skill": True}}},
    )

    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan.")

    skill_names = [us.skill.name for us in user.skills] if user.skills else []

    return {
        "status": "success",
        "data": {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "email": user.email,
            "skills": skill_names,
            "social_links": user.social_links,
            "created_at": tz_iso(user.created_at),
        },
    }