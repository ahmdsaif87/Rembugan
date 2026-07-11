import asyncio
import re
import secrets
from fastapi import Depends, HTTPException, UploadFile
from sqlalchemy import select, delete
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.models import User, Skill, UserSkill, Experience
from app.schemas.user import UserProfileInput
from app.core.tasks import fire_and_forget
from app.services.embedding import reembed_user
from app.services.ai_vision import extract_photo_from_pdf
from app.services.ai_nlp import extract_text_from_pdf, process_resume_with_ai
from app.services.storage import upload_image_to_cloudinary


class OnboardingService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

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
        result = await self.session.execute(select(User).where(User.id == uid))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User belum terdaftar. Silakan register dulu via /auth/register.")

        user.full_name = data.full_name
        user.bio = data.bio
        user.photo_url = data.photo_url
        user.is_onboarded = True
        if data.social_links:
            user.social_links = data.social_links
        await self.session.flush()

        # Skills
        await self.session.execute(delete(UserSkill).where(UserSkill.user_id == uid))
        if data.skills:
            existing_skills = await self.session.execute(
                select(Skill).where(Skill.name.in_(data.skills))
            )
            existing_skills_list = existing_skills.scalars().all()
            name_to_id = {s.name: s.id for s in existing_skills_list}

            new_names = [n for n in data.skills if n not in name_to_id]
            for skill_name in new_names:
                skill = Skill(name=skill_name)
                self.session.add(skill)
                await self.session.flush()
                name_to_id[skill_name] = skill.id

            for skill_name in data.skills:
                self.session.add(UserSkill(user_id=uid, skill_id=name_to_id[skill_name]))

        await self.session.commit()

        fire_and_forget(reembed_user(self.session, uid), name="reembed_user_onboarding")

        # Experiences
        await self.session.execute(delete(Experience).where(Experience.user_id == uid))

        from datetime import datetime, timezone

        for exp in data.experiences:
            start_date = exp.start_date or datetime.now(timezone.utc)
            end_date = exp.end_date
            self.session.add(Experience(
                user_id=uid,
                title=exp.title,
                company=exp.organization,
                description=exp.description,
                start_date=start_date,
                end_date=end_date,
            ))
        await self.session.commit()

        handle = user.handle
        if not handle:
            base = re.sub(r'[^a-z0-9]', '', user.full_name.lower())[:20]
            if not base:
                base = f"user{secrets.token_hex(4)}"
            handle = base + secrets.token_hex(2)
            user.handle = handle
            await self.session.commit()

        return {
            "id": user.id,
            "nim": user.nim,
            "full_name": user.full_name,
            "handle": handle,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "skills": data.skills,
        }

    async def get_my_profile(self, uid: str) -> dict:
        result = await self.session.execute(select(User).where(User.id == uid))
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan.")

        skill_names = [us.skill.name for us in (user.skills or [])]

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
