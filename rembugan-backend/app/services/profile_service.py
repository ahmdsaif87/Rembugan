import re
from datetime import datetime
from dataclasses import dataclass
from typing import Optional
from fastapi import Depends, HTTPException
from prisma import Prisma, Json
from app.core.database import get_db
from app.core.constants import PJ_OPEN, ROLE_KETUA, ROLE_ADMIN
from app.schemas.profile import SettingsUpdateInput
from app.schemas.user import ExperienceInput
from app.services.embedding import cosine_similarity, reembed_user
from app.services.base import BaseService


def _parse_date(s: str) -> datetime | None:
    s = s.strip()
    if not s:
        return None

    fmts = [
        "%Y-%m-%d", "%Y-%m", "%Y",
        "%d/%m/%Y", "%m/%Y",
        "%B %Y", "%b %Y",
    ]
    for fmt in fmts:
        try:
            dt = datetime.strptime(s, fmt)
            if fmt == "%Y":
                return datetime(dt.year, 1, 1)
            if fmt in ("%Y-%m", "%m/%Y"):
                return datetime(dt.year, dt.month, 1)
            return dt
        except ValueError:
            continue

    month_map = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        'januari': 1, 'februari': 2, 'maret': 3, 'april': 4, 'mei': 5, 'juni': 6,
        'juli': 7, 'agustus': 8, 'september': 9, 'oktober': 10, 'november': 11, 'desember': 12,
    }
    m = re.match(r'(\d{4})', s)
    if m:
        return datetime(int(m.group(1)), 1, 1)

    for name, month_num in month_map.items():
        if name in s.lower():
            em = re.search(r'(\d{4})', s)
            if em:
                return datetime(int(em.group(1)), month_num, 1)

    return None


def _parse_duration(duration: str) -> tuple[datetime, datetime | None]:
    if not duration or not duration.strip():
        now = datetime.now()
        return now, None

    parts = re.split(r'\s*[-–—]+\s*', duration.strip())
    if len(parts) == 2:
        start_str, end_str = parts[0].strip(), parts[1].strip()
        start = _parse_date(start_str) or datetime.now()
        end = None
        if end_str and end_str.lower() not in ('now', 'present', 'sekarang', 'saat ini'):
            end = _parse_date(end_str)
        return start, end

    parsed = _parse_date(duration.strip())
    if parsed:
        return parsed, None

    return datetime.now(), None


@dataclass
class ProfileService(BaseService):
    db: Prisma = Depends(get_db)

    async def update_settings(self, user_id: str, data: SettingsUpdateInput) -> dict:
        update_data = {}
        skill_names = None
        experiences = None

        if data.full_name is not None:
            name = data.full_name.strip()
            if not name:
                raise HTTPException(status_code=400, detail="Nama wajib diisi")
            update_data["full_name"] = name

        if data.handle is not None:
            existing = await self.db.user.find_first(
                where={"handle": data.handle, "id": {"not": user_id}}
            )
            if existing:
                raise HTTPException(status_code=400, detail="Username sudah digunakan")
            update_data["handle"] = data.handle

        if data.bio is not None:
            update_data["bio"] = data.bio
        if data.interest is not None:
            update_data["interest"] = data.interest
        if data.photo_url is not None:
            update_data["photo_url"] = data.photo_url
        if data.cover_url is not None:
            update_data["cover_url"] = data.cover_url
        if data.social_links is not None:
            update_data["social_links"] = Json(data.social_links)

        if update_data:
            await self.db.user.update(
                where={"id": user_id},
                data=update_data,
            )

        if data.skills is not None:
            skill_names = []
            seen = set()
            for raw_skill in data.skills:
                skill_name = raw_skill.strip()
                key = skill_name.lower()
                if skill_name and key not in seen:
                    seen.add(key)
                    skill_names.append(skill_name)

            await self.db.userskill.delete_many(where={"user_id": user_id})
            for skill_name in skill_names:
                skill = await self.db.skill.find_unique(where={"name": skill_name})
                if skill is None:
                    skill = await self.db.skill.create(data={"name": skill_name})
                await self.db.userskill.create(data={"user_id": user_id, "skill_id": skill.id})

        if data.experiences is not None:
            experiences = []
            await self.db.experience.delete_many(where={"user_id": user_id})
            for exp in data.experiences:
                start_date, end_date = _parse_duration(exp.duration)
                created = await self.db.experience.create(data={
                    "user_id": user_id,
                    "title": exp.title,
                    "company": exp.organization,
                    "description": exp.description,
                    "start_date": start_date,
                    "end_date": end_date,
                })
                experiences.append({
                    "id": created.id,
                    "title": created.title,
                    "company": created.company,
                    "description": created.description,
                    "start_date": created.start_date.isoformat(),
                    "end_date": created.end_date.isoformat() if created.end_date else None,
                })

        if update_data or data.skills is not None or data.experiences is not None:
            await reembed_user(self.db, user_id)

        user = await self.db.user.find_unique(
            where={"id": user_id},
            include={"experiences": True},
        )

        return {
            "handle": user.handle,
            "full_name": user.full_name,
            "bio": user.bio,
            "interest": user.interest,
            "photo_url": user.photo_url,
            "cover_url": user.cover_url,
            "social_links": user.social_links,
            "skills": skill_names if data.skills is not None else None,
            "experiences": experiences if data.experiences is not None else [
                {
                    "id": exp.id,
                    "title": exp.title,
                    "company": exp.company,
                    "description": exp.description,
                    "start_date": exp.start_date.isoformat(),
                    "end_date": exp.end_date.isoformat() if exp.end_date else None,
                }
                for exp in user.experiences
            ] if user.experiences else [],
        }

    async def get_recommended(self, user_id: str, limit: int) -> list[dict]:
        current_user = await self.db.user.find_unique(
            where={"id": user_id},
            include={"skills": {"include": {"skill": True}}, "ownedProjects": True},
        )
        if not current_user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        user_embedding = current_user.embedding
        open_projects = [p for p in (current_user.ownedProjects or []) if p.status == PJ_OPEN]
        has_open_offerings = len(open_projects) > 0

        project_required_skills: set[str] = set()
        if has_open_offerings:
            for p in open_projects:
                project_required_skills.update(p.required_skills or [])

        connections = await self.db.connection.find_many(
            where={
                "status": "accepted",
                "OR": [
                    {"sender_id": user_id},
                    {"receiver_id": user_id},
                ],
            },
        )
        connected_ids = set()
        for c in connections:
            other = c.receiver_id if c.sender_id == user_id else c.sender_id
            connected_ids.add(other)

        exclude_ids = [user_id, *connected_ids]
        others = await self.db.user.find_many(
            where={"id": {"notIn": exclude_ids}},
            take=20,
        )

        scored = []
        for u in others:
            u_emb = u.embedding
            score = 0
            if user_embedding and u_emb:
                score = int(cosine_similarity(user_embedding, u_emb) * 100)
            scored.append((score, u))

        scored.sort(key=lambda x: x[0], reverse=True)
        scored = scored[:limit]

        other_ids = [u.id for _, u in scored]

        # Batch fetch connections to avoid N+1 queries
        all_conns = await self.db.connection.find_many(
            where={
                "OR": [
                    {"sender_id": user_id, "receiver_id": {"in": other_ids}},
                    {"sender_id": {"in": other_ids}, "receiver_id": user_id},
                ]
            }
        )
        conn_map = {}
        for conn in all_conns:
            other = conn.receiver_id if conn.sender_id == user_id else conn.sender_id
            conn_map[other] = conn.status

        # Batch fetch users with skills
        users_with_skills = await self.db.user.find_many(
            where={"id": {"in": other_ids}},
            include={"skills": {"include": {"skill": True}}}
        )
        skills_map = {u.id: u.skills for u in users_with_skills}

        result = []
        for score, u in scored:
            u_skills = skills_map.get(u.id, [])
            conn_status = conn_map.get(u.id)
            result.append({
                "id": u.id,
                "full_name": u.full_name,
                "handle": u.handle,
                "nim": u.nim,
                "major": u.major,
                "bio": u.bio,
                "photo_url": u.photo_url,
                "skills": [s.skill.name for s in u_skills] if u_skills else [],
                "connection_status": conn_status,
            })

        return result

    async def search(self, query: str) -> list[dict]:
        users = await self.db.user.find_many(
            where={
                "OR": [
                    {"full_name": {"contains": query, "mode": "insensitive"}},
                    {"nim": {"contains": query}},
                ]
            },
            take=20,
            order={"full_name": "asc"},
        )

        result = []
        for u in users:
            result.append({
                "id": u.id,
                "full_name": u.full_name,
                "nim": u.nim,
                "bio": u.bio,
                "photo_url": u.photo_url,
                "major": u.major,
            })

        return result

    async def get_profile(self, target_user_id: str, user_token: dict | None = None) -> dict:
        user = await self.db.user.find_unique(
            where={"id": target_user_id},
            include={
                "skills": {"include": {"skill": True}},
                "experiences": True,
                "showcases": {"include": {"likes": True, "comments": True}},
                "ownedProjects": True,
                "memberships": {"include": {"project": True}},
            }
        )

        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        skills = [s.skill.name for s in user.skills] if user.skills else []

        all_projects = []
        if user.ownedProjects:
            for p in user.ownedProjects:
                all_projects.append({
                    "id": p.id,
                    "title": p.title,
                    "status": p.status,
                    "role": ROLE_KETUA,
                    "created_at": p.created_at.isoformat(),
                })
        if user.memberships:
            for m in user.memberships:
                all_projects.append({
                    "id": m.project.id,
                    "title": m.project.title,
                    "status": m.project.status,
                    "role": m.role,
                    "created_at": m.project.created_at.isoformat(),
                })
        all_projects.sort(key=lambda x: x["created_at"], reverse=True)

        connection_count = await self.db.connection.count(
            where={
                "OR": [
                    {"sender_id": user.id, "status": "accepted"},
                    {"receiver_id": user.id, "status": "accepted"},
                ]
            },
        )

        is_own_profile = user_token and user_token.get("uid") == user.id

        connection_status = None
        connection_id = None
        is_incoming = None
        if not is_own_profile and user_token:
            viewer_id = user_token.get("uid")
            existing_conn = await self.db.connection.find_first(
                where={
                    "OR": [
                        {"sender_id": viewer_id, "receiver_id": user.id},
                        {"sender_id": user.id, "receiver_id": viewer_id},
                    ]
                }
            )
            if existing_conn:
                connection_status = existing_conn.status
                connection_id = existing_conn.id
                is_incoming = existing_conn.receiver_id == viewer_id

        data = {
            "connection_status": connection_status,
            "connection_id": connection_id,
            "is_incoming": is_incoming,
            "connection_count": connection_count,
            "project_count": len(all_projects),
            "id": user.id,
            "full_name": user.full_name,
            "handle": user.handle,
            "interest": user.interest,
            "nim": user.nim,
            "faculty": user.faculty,
            "major": user.major,
            "bio": user.bio,
            "photo_url": user.photo_url,
            "cover_url": user.cover_url,
            "social_links": user.social_links,
            "skills": skills,
            "experiences": [
                {
                    "id": exp.id,
                    "title": exp.title,
                    "company": exp.company,
                    "description": exp.description,
                    "start_date": exp.start_date.isoformat(),
                    "end_date": exp.end_date.isoformat() if exp.end_date else None,
                } for exp in user.experiences
            ] if user.experiences else [],
            "project_history": all_projects,
            "portfolios": sorted([
                {
                    "id": s.id,
                    "content": s.content,
                    "media_urls": s.media_urls,
                    "tags": s.tags,
                    "likes_count": len(s.likes) if s.likes else 0,
                    "comments_count": len(s.comments) if s.comments else 0,
                    "created_at": s.created_at.isoformat(),
                } for s in user.showcases
            ], key=lambda x: x["created_at"], reverse=True) if user.showcases else [],
        }

        if is_own_profile or (user_token and user_token.get("role") == ROLE_ADMIN):
            data["email"] = user.email
            data["email_verified"] = user.email_verified

        return data
