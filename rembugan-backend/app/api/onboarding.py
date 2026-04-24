from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from prisma import Prisma, Json
from zoneinfo import ZoneInfo

from app.core.security import verify_token
from app.core.database import get_db
from app.schemas.user import UserProfileInput
from app.services.ai_vision import extract_photo_from_pdf
from app.services.ai_nlp import extract_text_from_pdf, process_resume_with_gemini
from app.services.storage import upload_image_to_cloudinary

router = APIRouter(prefix="/onboarding", tags=["1. AI & Onboarding"])


@router.post("/extract-cv", summary="Ekstrak Data CV (OCR + Gemini)")
async def extract_cv_data(file: UploadFile = File(...)):
    """
    Upload file PDF CV, lalu:
    1. Ekstrak foto profil dari PDF
    2. OCR seluruh teks dari PDF
    3. Gemini AI merapikan teks menjadi data terstruktur (nama, skills, bio)
    """
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Format file harus PDF!")

    file_bytes = await file.read()

    # 1. Ekstrak foto dari PDF
    photo_url = None
    try:
        photo_bytes = extract_photo_from_pdf(file_bytes)
        if photo_bytes:
            photo_url = upload_image_to_cloudinary(photo_bytes)
    except Exception:
        pass  # Foto opsional, tidak perlu gagalkan proses

    # 2. Ekstrak teks mentah via OCR
    raw_text = extract_text_from_pdf(file_bytes)

    # 3. Rapikan teks menjadi JSON pakai Gemini
    ai_result = process_resume_with_gemini(raw_text)

    return {
        "status": "success",
        "message": "Analisis CV selesai!",
        "data": {
            "photo_url": photo_url,
            "nama": ai_result.get("nama", "Tidak Terdeteksi"),
            "skills_terdeteksi": ai_result.get("skills", []),
            "bio_suggestion": ai_result.get("bio_suggestion", "")
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

    # 1. Update profil user
    update_data = {
        "full_name": data.full_name,
        "bio": data.bio,
        "photo_url": data.photo_url,
        "is_onboarded": True,
    }

    if data.social_links:
        update_data["social_links"] = Json(data.social_links)

    user = await db.user.update(
        where={"id": uid},
        data=update_data,
    )

    # 2. Sinkronisasi Skills
    await db.userskill.delete_many(where={"user_id": uid})

    for skill_name in data.skills:
        skill = await db.skill.upsert(
            where={"name": skill_name},
            data={
                "create": {"name": skill_name},
                "update": {},
            },
        )
        await db.userskill.create(
            data={
                "user_id": uid,
                "skill_id": skill.id,
            }
        )

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
            "google_linked": user.googleId is not None,
            "created_at": user.created_at.astimezone(ZoneInfo("Asia/Jakarta")).isoformat(),
        },
    }