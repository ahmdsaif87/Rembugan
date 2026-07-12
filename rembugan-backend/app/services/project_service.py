from dataclasses import dataclass
from fastapi import Depends, HTTPException
from sqlalchemy import select, text, func
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.dates import tz_iso
from app.core.constants import PJ_OPEN, PJ_COMPLETED, ROLE_KETUA, EXPLORE_MAX_ROWS
from app.core.types import ProjectData
from app.models import User, Project, ProjectMember, ProjectApplication, Skill
from app.services.base import BaseService
from app.core.cache import cache
from app.core.tasks import fire_and_forget
from app.services.embedding import cosine_similarity, reembed_project, reembed_user


@dataclass
class ProjectService(BaseService):
    session: AsyncSession = Depends(get_db_session)

    async def create_project(self, data, user_id: str) -> ProjectData:
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User belum terdaftar. Harap selesaikan onboarding.")

        project = Project(
            owner_id=user_id,
            title=data.title,
            description=data.description,
            required_skills=data.required_skills,
            category=data.category,
            deadline=data.deadline,
            total_slots=data.total_slots,
        )
        self.session.add(project)
        await self.session.flush()

        member = ProjectMember(project_id=project.id, user_id=user_id, role=ROLE_KETUA)
        self.session.add(member)
        await self.session.commit()
        await self.session.refresh(project)

        fire_and_forget(reembed_project(project.id), name="reembed_project")
        fire_and_forget(reembed_user(user_id), name="reembed_user")

        await cache.invalidate("explore:")
        return {
            "id": project.id,
            "title": project.title,
            "description": project.description,
            "required_skills": project.required_skills,
            "status": project.status,
            "category": project.category,
            "deadline": tz_iso(project.deadline) if project.deadline else None,
            "total_slots": project.total_slots,
            "filled_slots": 1,
            "owner": user.full_name,
            "created_at": tz_iso(project.created_at),
        }

    async def get_explore(
        self,
        user_id: str,
        page_params,
        category: str = None,
        min_slots: int = None,
        max_slots: int = None,
        deadline_before: str = None,
    ) -> dict:
        result = await self.session.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User belum terdaftar.")

        cache_key = f"explore:{user_id}:{page_params.page}:{page_params.limit}:{category}:{min_slots}:{max_slots}:{deadline_before}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached

        user_embedding = None
        raw = await self.session.execute(
            text('SELECT embedding::text FROM "User" WHERE id = :uid'),
            {"uid": user_id},
        )
        emb_row = raw.fetchone()
        if emb_row and emb_row[0]:
            import json
            user_embedding = json.loads(emb_row[0])

        user_skill_names = {s.skill.name.lower() for s in (user.skills or [])}
        user_has_skills = bool(user_skill_names)

        # Build where clause for count + query
        query = select(Project).where(Project.status == PJ_OPEN)
        if category:
            query = query.where(Project.category == category)
        if min_slots is not None:
            query = query.where(Project.total_slots >= min_slots)
        if max_slots is not None:
            query = query.where(Project.total_slots <= max_slots)
        if deadline_before:
            from datetime import datetime
            try:
                dt = datetime.fromisoformat(deadline_before)
                query = query.where(Project.deadline <= dt)
            except ValueError:
                pass

        count_query = select(func.count()).select_from(query.subquery())
        total_result = await self.session.execute(count_query)
        total = total_result.scalar() or 0

        fetch_limit = min(total, EXPLORE_MAX_ROWS)
        if fetch_limit == 0:
            return {"data": [], "total": 0, "page": page_params.page, "limit": page_params.limit}

        result = await self.session.execute(
            query.order_by(Project.created_at.desc())
            .offset(page_params.skip)
            .limit(page_params.take)
        )
        projects = result.scalars().all()

        # My applications
        result = await self.session.execute(
            select(ProjectApplication).where(ProjectApplication.applicant_id == user_id)
        )
        my_apps = result.scalars().all()
        applied_ids = {a.project_id for a in my_apps}

        # My memberships
        result = await self.session.execute(
            select(ProjectMember).where(ProjectMember.user_id == user_id)
        )
        my_memberships = result.scalars().all()
        member_ids = {m.project_id for m in my_memberships}

        # Batch fetch embeddings
        project_ids = [p.id for p in projects]
        project_embeddings = {}
        if project_ids:
            ids_list = ", ".join(str(i) for i in project_ids)
            raw = await self.session.execute(
                text(f'SELECT id, embedding::text FROM "Project" WHERE id IN ({ids_list})')
            )
            for r in raw.fetchall():
                if r[1]:
                    import json
                    project_embeddings[r[0]] = json.loads(r[1])

        # Batch fetch owners
        owner_ids = list(set(p.owner_id for p in projects))
        owners_map = {}
        if owner_ids:
            result = await self.session.execute(select(User).where(User.id.in_(owner_ids)))
            owners_map = {u.id: u for u in result.scalars().all()}

        scored = []
        for p in projects:
            score = 0
            p_emb = project_embeddings.get(p.id)
            if user_embedding and p_emb:
                score = round(cosine_similarity(user_embedding, p_emb) * 100)
            elif user_has_skills and p.required_skills:
                req_skills = {s.lower() for s in (p.required_skills or [])} - {""}
                if req_skills & user_skill_names:
                    score = round(len(req_skills & user_skill_names) / len(req_skills) * 100)

            if user_has_skills and score > 0:
                req_skills = {s.lower() for s in (p.required_skills or [])} - {""}
                if req_skills and not (req_skills & user_skill_names):
                    score = 0

            owner = owners_map.get(p.owner_id)
            member_names = [m.user.full_name for m in (p.members or []) if m.user]
            member_avatars = [m.user.photo_url or '' for m in (p.members or []) if m.user]

            scored.append({
                "id": p.id,
                "title": p.title,
                "description": p.description,
                "required_skills": p.required_skills,
                "status": p.status,
                "category": p.category,
                "deadline": tz_iso(p.deadline) if p.deadline else None,
                "total_slots": p.total_slots,
                "filled_slots": len(p.members) if p.members else 0,
                "owner_name": owner.full_name if owner else None,
                "owner_photo": owner.photo_url if owner else None,
                "owner_id": p.owner_id,
                "member_names": member_names,
                "member_avatars": member_avatars,
                "match_score": score,
                "has_applied": p.id in applied_ids,
                "is_member": p.id in member_ids,
                "is_owner": p.owner_id == user_id,
                "created_at": tz_iso(p.created_at),
            })

        scored.sort(key=lambda x: x["match_score"], reverse=True)

        result_data = {
            "data": scored,
            "total": total,
            "page": page_params.page,
            "limit": page_params.limit,
        }
        await cache.set(cache_key, result_data, ttl=300)
        return result_data

    async def get_my_projects(self, user_id: str, skip: int = 0, limit: int = 20) -> list[ProjectData]:
        result = await self.session.execute(
            select(Project)
            .where(Project.owner_id == user_id)
            .order_by(Project.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        projects = result.scalars().all()

        result_data = []
        for p in projects:
            result_data.append({
                "id": p.id,
                "title": p.title,
                "description": p.description,
                "required_skills": p.required_skills,
                "status": p.status,
                "category": p.category,
                "deadline": tz_iso(p.deadline) if p.deadline else None,
                "total_slots": p.total_slots,
                "filled_slots": len(p.members) if p.members else 0,
                "member_count": len(p.members) if p.members else 0,
                "created_at": tz_iso(p.created_at),
            })
        return result_data

    async def get_detail(self, project_id: int) -> ProjectData:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        from app.models.collaboration import Task, TaskAssignee

        # Fetch members with users
        result = await self.session.execute(
            select(ProjectMember).where(ProjectMember.project_id == project_id)
        )
        members = result.scalars().all()

        member_user_ids = [m.user_id for m in members]
        users_map = {}
        if member_user_ids:
            result = await self.session.execute(select(User).where(User.id.in_(member_user_ids)))
            users_map = {u.id: u for u in result.scalars().all()}

        members_list = []
        for m in members:
            u = users_map.get(m.user_id)
            members_list.append({
                "id": m.id,
                "user_id": m.user_id,
                "name": u.full_name if u else None,
                "role": m.role,
            })

        # Fetch tasks with assignees
        result = await self.session.execute(
            select(Task).where(Task.project_id == project_id)
        )
        tasks = result.scalars().all()

        task_ids = [t.id for t in tasks]
        assignees_map = {}
        if task_ids:
            result = await self.session.execute(
                select(TaskAssignee).where(TaskAssignee.task_id.in_(task_ids))
            )
            assignees = result.scalars().all()
            assignee_user_ids = list(set(a.user_id for a in assignees))
            assignee_users = {}
            if assignee_user_ids:
                result = await self.session.execute(select(User).where(User.id.in_(assignee_user_ids)))
                assignee_users = {u.id: u for u in result.scalars().all()}
            for a in assignees:
                assignees_map.setdefault(a.task_id, []).append(a)

        tasks_list = []
        for t in tasks:
            task_assignees = assignees_map.get(t.id, [])
            tasks_list.append({
                "id": t.id,
                "title": t.title,
                "status": t.status,
                "assignees": [
                    {"id": a.user_id, "name": assignee_users.get(a.user_id).full_name if assignee_users.get(a.user_id) else None}
                    for a in task_assignees
                ],
            })

        # Fetch owner
        result = await self.session.execute(select(User).where(User.id == project.owner_id))
        owner = result.scalar_one_or_none()

        return {
            "id": project.id,
            "title": project.title,
            "description": project.description,
            "required_skills": project.required_skills,
            "status": project.status,
            "category": project.category,
            "deadline": tz_iso(project.deadline) if project.deadline else None,
            "total_slots": project.total_slots,
            "filled_slots": len(members),
            "owner_name": owner.full_name if owner else None,
            "members": members_list,
            "tasks": tasks_list,
            "created_at": tz_iso(project.created_at),
        }

    async def get_suggestions(self) -> dict:
        result = await self.session.execute(
            select(Project).where(Project.status == PJ_OPEN)
        )
        projects = result.scalars().all()
        categories = sorted({p.category for p in projects if p.category})
        skills = sorted({
            s for p in projects
            for s in (p.required_skills or [])
            if s
        })

        from app.models.social import Showcase
        result = await self.session.execute(select(Showcase))
        showcases = result.scalars().all()
        tags = sorted({
            t for s in showcases
            for t in (s.tags or [])
            if t
        })

        return {"categories": categories, "skills": skills, "tags": tags}

    async def archive_project(self, project_id: int, user_id: str) -> ProjectData:
        result = await self.session.execute(select(Project).where(Project.id == project_id))
        project = result.scalar_one_or_none()
        if not project:
            raise HTTPException(status_code=404, detail="Project not found.")
        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Only the owner can archive the project.")

        project.status = PJ_COMPLETED
        await self.session.commit()
        return {"id": project.id, "status": project.status}
