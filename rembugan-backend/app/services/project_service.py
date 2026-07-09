from dataclasses import dataclass
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.dates import tz_iso
from app.core.constants import PJ_OPEN, PJ_COMPLETED, ROLE_KETUA, EXPLORE_MAX_ROWS
from app.core.types import ProjectData
from app.services.base import BaseService
from app.core.cache import cache
from app.services.embedding import cosine_similarity, reembed_project, reembed_user


@dataclass
class ProjectService(BaseService):
    db: Prisma = Depends(get_db)

    async def create_project(self, data, user_id: str) -> ProjectData:
        user = await self.db.user.find_unique(where={"id": user_id})
        if not user:
            raise HTTPException(status_code=404, detail="User belum terdaftar. Harap selesaikan onboarding.")

        create_data = {
            "owner_id": user_id,
            "title": data.title,
            "description": data.description,
            "required_skills": data.required_skills,
            "members": {"create": {"user_id": user_id, "role": ROLE_KETUA}},
        }
        if data.category is not None:
            create_data["category"] = data.category
        if data.deadline is not None:
            create_data["deadline"] = data.deadline
        if data.total_slots is not None:
            create_data["total_slots"] = data.total_slots

        project = await self.db.project.create(
            data=create_data,
            include={"owner": True, "members": True},
        )

        await reembed_project(self.db, project.id)
        await reembed_user(self.db, user_id)

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
            "filled_slots": len(project.members) if project.members else 0,
            "owner": project.owner.full_name if project.owner else None,
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
        user = await self.db.user.find_unique(
            where={"id": user_id},
            include={"skills": {"include": {"skill": True}}},
        )
        if not user:
            raise HTTPException(status_code=404, detail="User belum terdaftar.")

        cache_key = f"explore:{user_id}:{page_params.page}:{page_params.limit}:{category}:{min_slots}:{max_slots}:{deadline_before}"
        cached = await cache.get(cache_key)
        if cached is not None:
            return cached

        user_embedding = None
        emb_row = await self.db.query_raw('SELECT embedding::text FROM "User" WHERE id = $1', user_id)
        if emb_row and emb_row[0]["embedding"]:
            import json
            user_embedding = json.loads(emb_row[0]["embedding"])
        user_skill_names = {s.skill.name.lower() for s in user.skills} if user.skills else set()
        user_has_skills = bool(user_skill_names)

        where = {"status": PJ_OPEN}
        if category:
            where["category"] = category
        if min_slots is not None or max_slots is not None:
            slots_filter = {}
            if min_slots is not None:
                slots_filter["gte"] = min_slots
            if max_slots is not None:
                slots_filter["lte"] = max_slots
            where["total_slots"] = slots_filter
        if deadline_before:
            from datetime import datetime
            try:
                dt = datetime.fromisoformat(deadline_before)
                where["deadline"] = {"lte": dt}
            except ValueError:
                pass

        total = await self.db.project.count(where=where)
        fetch_limit = min(total, EXPLORE_MAX_ROWS)
        if fetch_limit == 0:
            return {"data": [], "total": 0, "page": page_params.page, "limit": page_params.limit}

        projects = await self.db.project.find_many(
            where=where,
            include={"owner": True, "members": True},
            order={"created_at": "desc"},
            skip=page_params.skip,
            take=page_params.take,
        )

        my_apps = await self.db.projectapplication.find_many(
            where={"applicant_id": user_id},
        )
        applied_ids = {a.project_id for a in my_apps}

        my_memberships = await self.db.projectmember.find_many(
            where={"user_id": user_id},
        )
        member_ids = {m.project_id for m in my_memberships}

        # Batch fetch embeddings untuk scoring
        project_ids = [p.id for p in projects]
        ids_str = ", ".join(str(i) for i in project_ids)
        emb_rows = await self.db.query_raw(
            f'SELECT id, embedding::text FROM "Project" WHERE id IN ({ids_str})'
        ) if project_ids else []
        project_embeddings = {}
        for r in emb_rows:
            if r["embedding"]:
                import json
                project_embeddings[r["id"]] = json.loads(r["embedding"])

        scored = []
        for p in projects:
            score = 0
            p_emb = project_embeddings.get(p.id)
            if user_embedding and p_emb:
                score = int(cosine_similarity(user_embedding, p_emb) * 100)

            if user_has_skills:
                req_skills = {s.lower() for s in (p.required_skills or [])} - {""}
                if req_skills and not (req_skills & user_skill_names):
                    score = 0

            member_names = [m.user.full_name for m in p.members if m.user] if p.members else []
            member_avatars = [m.user.photo_url or '' for m in p.members if m.user] if p.members else []

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
                "owner_name": p.owner.full_name if p.owner else None,
                "owner_photo": p.owner.photo_url if p.owner else None,
                "owner_id": p.owner.id if p.owner else None,
                "member_names": member_names,
                "member_avatars": member_avatars,
                "match_score": score,
                "has_applied": p.id in applied_ids,
                "is_member": p.id in member_ids,
                "is_owner": p.owner_id == user_id,
                "created_at": tz_iso(p.created_at),
            })

        scored.sort(key=lambda x: x["match_score"], reverse=True)

        result = {
            "data": scored,
            "total": total,
            "page": page_params.page,
            "limit": page_params.limit,
        }
        await cache.set(cache_key, result, ttl=300)
        return result

    async def get_my_projects(self, user_id: str) -> list[ProjectData]:
        projects = await self.db.project.find_many(
            where={"owner_id": user_id},
            include={"members": True},
            order={"created_at": "desc"},
        )

        result = []
        for p in projects:
            result.append({
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
        return result

    async def get_detail(self, project_id: int) -> ProjectData:
        project = await self.db.project.find_unique(
            where={"id": project_id},
            include={
                "owner": True,
                "members": {"include": {"user": True}},
                "tasks": {"include": {"assignees": {"include": {"user": True}}}},
                "applications": {"include": {"applicant": True}},
            },
        )
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

        members = []
        if project.members:
            for m in project.members:
                members.append({
                    "id": m.id,
                    "user_id": m.user_id,
                    "name": m.user.full_name if m.user else None,
                    "role": m.role,
                })

        tasks = []
        if project.tasks:
            for t in project.tasks:
                tasks.append({
                    "id": t.id,
                    "title": t.title,
                    "status": t.status,
                    "assignees": [
                        {"id": a.user_id, "name": a.user.full_name}
                        for a in (t.assignees or [])
                    ],
                })

        return {
            "id": project.id,
            "title": project.title,
            "description": project.description,
            "required_skills": project.required_skills,
            "status": project.status,
            "category": project.category,
            "deadline": tz_iso(project.deadline) if project.deadline else None,
            "total_slots": project.total_slots,
            "filled_slots": len(project.members) if project.members else 0,
            "owner_name": project.owner.full_name if project.owner else None,
            "members": members,
            "tasks": tasks,
            "created_at": tz_iso(project.created_at),
        }

    async def get_suggestions(self) -> dict:
        projects = await self.db.project.find_many(
            where={"status": PJ_OPEN},
        )
        categories = sorted({p.category for p in projects if p.category})
        skills = sorted({
            s for p in projects
            for s in (p.required_skills or [])
            if s
        })

        showcases = await self.db.showcase.find_many()
        tags = sorted({
            t for s in showcases
            for t in (s.tags or [])
            if t
        })

        return {"categories": categories, "skills": skills, "tags": tags}

    async def archive_project(self, project_id: int, user_id: str) -> ProjectData:
        project = await self.db.project.find_unique(
            where={"id": project_id},
            select={"owner_id": True, "status": True},
        )
        if not project:
            raise HTTPException(status_code=404, detail="Project not found.")
        if project.owner_id != user_id:
            raise HTTPException(status_code=403, detail="Only the owner can archive the project.")

        updated = await self.db.project.update(
            where={"id": project_id},
            data={"status": PJ_COMPLETED},
            select={"id": True, "status": True},
        )
        return {"id": updated.id, "status": updated.status}
