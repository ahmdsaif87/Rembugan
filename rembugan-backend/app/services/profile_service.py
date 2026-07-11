import re
import json
from datetime import datetime
from fastapi import Depends, HTTPException
from sqlalchemy import select, or_, and_, func as sa_func, text, delete
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.constants import PJ_OPEN, ROLE_KETUA, ROLE_ADMIN
from app.schemas.profile import SettingsUpdateInput
from app.core.cache import cache
from app.models import User, Skill, UserSkill, Experience, Project, ProjectMember, Showcase, Connection


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


class ProfileService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def update_settings(self, user_id: str, data: SettingsUpdateInput) -> dict:
        update_data = {}
        skill_names = None
        experiences = None

        stmt = select(User).where(User.id == user_id)
        result = await self.session.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        if data.full_name is not None:
            name = data.full_name.strip()
            if not name:
                raise HTTPException(status_code=400, detail="Nama wajib diisi")
            user.full_name = name

        if data.handle is not None:
            existing = await self.session.execute(
                select(User).where(and_(User.handle == data.handle, User.id != user_id))
            )
            if existing.scalar_one_or_none():
                raise HTTPException(status_code=400, detail="Username sudah digunakan")
            user.handle = data.handle

        if data.bio is not None:
            user.bio = data.bio
        if data.interest is not None:
            user.interest = data.interest
        if data.photo_url is not None:
            user.photo_url = data.photo_url
        if data.cover_url is not None:
            user.cover_url = data.cover_url
        if data.social_links is not None:
            user.social_links = data.social_links

        await self.session.flush()

        if data.skills is not None:
            skill_names = []
            seen = set()
            for raw_skill in data.skills:
                skill_name = raw_skill.strip()
                key = skill_name.lower()
                if skill_name and key not in seen:
                    seen.add(key)
                    skill_names.append(skill_name)

            await self.session.execute(
                delete(UserSkill).where(UserSkill.user_id == user_id)
            )
            for skill_name in skill_names:
                stmt = select(Skill).where(Skill.name == skill_name)
                skill = (await self.session.execute(stmt)).scalar_one_or_none()
                if skill is None:
                    skill = Skill(name=skill_name)
                    self.session.add(skill)
                    await self.session.flush()
                self.session.add(UserSkill(user_id=user_id, skill_id=skill.id))

        if data.experiences is not None:
            experiences = []
            await self.session.execute(
                delete(Experience).where(Experience.user_id == user_id)
            )
            for exp in data.experiences:
                start_date, end_date = _parse_duration(exp.duration)
                created = Experience(
                    user_id=user_id,
                    title=exp.title,
                    company=exp.organization,
                    description=exp.description,
                    start_date=start_date,
                    end_date=end_date,
                )
                self.session.add(created)
                await self.session.flush()
                experiences.append({
                    "id": created.id,
                    "title": created.title,
                    "company": created.company,
                    "description": created.description,
                    "start_date": created.start_date.isoformat(),
                    "end_date": created.end_date.isoformat() if created.end_date else None,
                })

        await self.session.commit()

        # Refetch for response
        stmt = select(User).where(User.id == user_id)
        user = (await self.session.execute(stmt)).scalar_one()

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
        cache_key = f"recommended:{user_id}:{limit}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached

        stmt = select(User).where(User.id == user_id)
        current_user = (await self.session.execute(stmt)).scalar_one_or_none()
        if not current_user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        # Get embedding
        raw = await self.session.execute(
            text('SELECT embedding::text FROM "User" WHERE id = :uid'),
            {"uid": user_id},
        )
        emb_row = raw.fetchone()
        user_embedding = json.loads(emb_row[0]) if emb_row and emb_row[0] else None

        # Get user's open projects
        stmt = select(Project).where(and_(Project.owner_id == user_id, Project.status == PJ_OPEN))
        open_projects = (await self.session.execute(stmt)).scalars().all()
        has_open_offerings = len(open_projects) > 0

        project_required_skills: set[str] = set()
        if has_open_offerings:
            for p in open_projects:
                project_required_skills.update(p.required_skills or [])

        # Get connected user IDs
        stmt = select(Connection).where(
            and_(
                Connection.status == "accepted",
                or_(Connection.sender_id == user_id, Connection.receiver_id == user_id),
            )
        )
        connections = (await self.session.execute(stmt)).scalars().all()
        connected_ids = set()
        for c in connections:
            other = c.receiver_id if c.sender_id == user_id else c.sender_id
            connected_ids.add(other)

        exclude_ids = [user_id, *connected_ids]
        exclude_list = ", ".join(f"'{e}'" for e in exclude_ids)

        rows = []
        if user_embedding:
            vec = f'[{",".join(str(x) for x in user_embedding)}]'
            raw = await self.session.execute(
                text(
                    f'SELECT id, full_name, photo_url, major, bio, '
                    f'1 - (embedding <=> \'{vec}\'::vector) AS match_score '
                    f'FROM "User" WHERE id NOT IN ({exclude_list}) '
                    'AND embedding IS NOT NULL '
                    f'ORDER BY embedding <=> \'{vec}\'::vector LIMIT :lim'
                ),
                {"lim": limit},
            )
            rows = raw.fetchall()

        other_ids = [r[0] for r in rows]

        # Batch fetch connection status
        conn_map = {}
        if other_ids:
            stmt = select(Connection).where(
                or_(
                    and_(Connection.sender_id == user_id, Connection.receiver_id.in_(other_ids)),
                    and_(Connection.sender_id.in_(other_ids), Connection.receiver_id == user_id),
                )
            )
            conns = (await self.session.execute(stmt)).scalars().all()
            for conn in conns:
                other = conn.receiver_id if conn.sender_id == user_id else conn.sender_id
                conn_map[other] = conn.status

        # Batch fetch users with skills
        skills_map = {}
        if other_ids:
            stmt = select(User).where(User.id.in_(other_ids))
            users = (await self.session.execute(stmt)).scalars().all()
            for u in users:
                skills_map[u.id] = [s.skill.name for s in (u.skills or [])]

        result = []
        for r in rows:
            uid = r[0]
            u_skills = skills_map.get(uid, [])
            conn_status = conn_map.get(uid)
            result.append({
                "id": uid,
                "full_name": r[1],
                "handle": None,
                "nim": None,
                "major": r[3],
                "bio": r[4],
                "photo_url": r[2],
                "skills": u_skills,
                "connection_status": conn_status,
            })

        await cache.set(cache_key, result, ttl=60)
        return result

    async def search(self, query: str) -> list[dict]:
        stmt = (
            select(User)
            .where(
                or_(
                    User.full_name.ilike(f"%{query}%"),
                    User.nim.ilike(f"%{query}%"),
                )
            )
            .order_by(User.full_name.asc())
            .limit(20)
        )
        users = (await self.session.execute(stmt)).scalars().all()
        return [
            {
                "id": u.id,
                "full_name": u.full_name,
                "nim": u.nim,
                "bio": u.bio,
                "photo_url": u.photo_url,
                "major": u.major,
            }
            for u in users
        ]

    async def get_profile(self, target_user_id: str, user_token: dict | None = None) -> dict:
        stmt = (
            select(User)
            .options(
                selectinload(User.skills).selectinload(UserSkill.skill),
                selectinload(User.experiences),
            )
            .where(User.id == target_user_id)
        )
        user = (await self.session.execute(stmt)).scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User tidak ditemukan")

        skills = [s.skill.name for s in (user.skills or [])]

        # Get all projects (owned + member)
        stmt = select(Project).where(Project.owner_id == target_user_id)
        owned_projects = (await self.session.execute(stmt)).scalars().all()
        stmt = select(ProjectMember).where(ProjectMember.user_id == target_user_id)
        memberships = (await self.session.execute(stmt)).scalars().all()

        all_projects = []
        seen_ids = set()
        for p in owned_projects:
            seen_ids.add(p.id)
            all_projects.append({
                "id": p.id,
                "title": p.title,
                "status": p.status,
                "role": ROLE_KETUA,
                "created_at": p.created_at.isoformat(),
            })
        member_project_ids = [m.project_id for m in memberships if m.project_id not in seen_ids]
        if member_project_ids:
            stmt = select(Project).where(Project.id.in_(member_project_ids))
            member_projects = (await self.session.execute(stmt)).scalars().all()
            mp_map = {p.id: p for p in member_projects}
            for m in memberships:
                if m.project_id not in seen_ids:
                    seen_ids.add(m.project_id)
                    p = mp_map.get(m.project_id)
                    if p:
                        all_projects.append({
                            "id": p.id,
                            "title": p.title,
                            "status": p.status,
                            "role": m.role,
                            "created_at": p.created_at.isoformat(),
                        })
        all_projects.sort(key=lambda x: x["created_at"], reverse=True)

        # Connection count
        raw = await self.session.execute(
            text("""
                SELECT COUNT(*) FROM "Connection"
                WHERE ("sender_id" = :uid OR "receiver_id" = :uid) AND status = 'accepted'
            """),
            {"uid": target_user_id},
        )
        connection_count = raw.scalar() or 0

        # Showcases
        stmt = (
            select(Showcase)
            .options(selectinload(Showcase.likes), selectinload(Showcase.comments))
            .where(Showcase.author_id == target_user_id)
        )
        showcases = (await self.session.execute(stmt)).scalars().all()

        is_own_profile = user_token and user_token.get("uid") == target_user_id

        connection_status = None
        connection_id = None
        is_incoming = None
        if not is_own_profile and user_token:
            viewer_id = user_token.get("uid")
            stmt = select(Connection).where(
                or_(
                    and_(Connection.sender_id == viewer_id, Connection.receiver_id == target_user_id),
                    and_(Connection.sender_id == target_user_id, Connection.receiver_id == viewer_id),
                )
            )
            existing_conn = (await self.session.execute(stmt)).scalar_one_or_none()
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
                } for s in showcases
            ], key=lambda x: x["created_at"], reverse=True) if showcases else [],
        }

        if is_own_profile or (user_token and user_token.get("role") == ROLE_ADMIN):
            data["email"] = user.email
            data["email_verified"] = user.email_verified

        return data
