import asyncio
from fastapi import Depends, HTTPException, UploadFile
from prisma import Prisma, Json
from app.core.database import get_db
from app.schemas.user import UserProfileInput
from app.services.embedding import reembed_user
from app.services.ai_vision import extract_photo_from_pdf
from app.services.ai_nlp import extract_text_from_pdf, process_resume_with_ai
from app.services.storage import upload_image_to_cloudinary


class OnboardingService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    def _format_nama(self, nama: str) -> str:
        if not nama or nama == "Tidak Terdeteksi":
            return nama
        return nama.title()

    async def extract_cv(self, file: UploadFile) -> dict:
        if not file.filename.endswith('.pdf'):
            raise HTTPException(status_code=400, detail="Format file harus PDF!")

        file_bytes = await file.read()

        loop = asyncio.get_running_loop()

        photo_url = None
        try:
            photo_bytes = await loop.run_in_executor(None, extract_photo_from_pdf, file_bytes)
            if photo_bytes:
                photo_url = await upload_image_to_cloudinary(photo_bytes)
        except Exception:
            pass

        raw_text = await loop.run_in_executor(None, extract_text_from_pdf, file_bytes)

        ai_result = await loop.run_in_executor(None, process_resume_with_ai, raw_text)

        return {
            "photo_url": photo_url,
            "nama": self._format_nama(ai_result.get("nama", "Tidak Terdeteksi")),
            "major": ai_result.get("major", ""),
            "skills_terdeteksi": ai_result.get("skills", []),
            "bio_suggestion": ai_result.get("bio_suggestion", ""),
            "experiences": ai_result.get("experiences", []),
        }

    async def save_profile(self, uid: str, data: UserProfileInput) -> dict:
        existing = await self.db.user.find_unique(where={"id": uid})
        if not existing:
            raise HTTPException(status_code=404, detail="User belum terdaftar. Silakan register dulu via /auth/register.")

        update_data = {
            "full_name": data.full_name,
            "bio": data.bio,
            "photo_url": data.photo_url,
            "is_onboarded": True,
        }

        if data.social_links:
            update_data["social_links"] = Json(data.social_links)

        user = await self.db.user.update(
            where={"id": uid},
            data=update_data,
        )

        await self.db.userskill.delete_many(where={"user_id": uid})

        if data.skills:
            existing_skills = await self.db.skill.find_many(
                where={"name": {"in": data.skills}}
            )
            name_to_id = {s.name: s.id for s in existing_skills}

            new_names = [n for n in data.skills if n not in name_to_id]
            if new_names:
                await self.db.skill.create_many(data=[{"name": n} for n in new_names])
                new_skills = await self.db.skill.find_many(
                    where={"name": {"in": new_names}}
                )
                for s in new_skills:
                    name_to_id[s.name] = s.id

            await self.db.userskill.create_many(
                data=[{"user_id": uid, "skill_id": name_to_id[n]} for n in data.skills]
            )

        await reembed_user(self.db, uid)

        await self.db.experience.delete_many(where={"user_id": uid})

        for exp in data.experiences:
            start_date, end_date = exp.start_date, exp.end_date
            await self.db.experience.create(data={
                "user_id": uid,
                "title": exp.title,
                "company": exp.organization,
                "description": exp.description,
                "start_date": start_date,
                "end_date": end_date,
            })

        return {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "skills": data.skills,
        }

    async def get_my_profile(self, uid: str) -> dict:
        user = await self.db.user.find_unique(
            where={"id": uid},
            include={"skills": {"include": {"skill": True}}},
        )

        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan.")

        skill_names = [us.skill.name for us in user.skills] if user.skills else []

        return {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "email": user.email,
            "skills": skill_names,
            "social_links": user.social_links,
            "created_at": user.created_at.isoformat(),
        }
