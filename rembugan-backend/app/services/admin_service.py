import asyncio
from fastapi import Depends, HTTPException
from prisma import Prisma
from app.core.database import get_db
from app.core.security import hash_password
from app.schemas.auth import AdminCreateUserInput, AdminResetPasswordInput, ImportUsersInput
from app.core.constants import PJ_COMPLETED, APP_PENDING
from app.services.competitions import get_competition_collection


class AdminService:
    def __init__(self, db: Prisma = Depends(get_db)):
        self.db = db

    async def reset_user_password(self, nim: str, new_password: str):
        user = await self.db.user.find_unique(where={"nim": nim})
        if not user:
            raise HTTPException(status_code=404, detail="User dengan NIM tersebut tidak ditemukan.")
        new_hashed = hash_password(new_password)
        await self.db.user.update(
            where={"id": user.id},
            data={"password": new_hashed},
        )

    async def create_user(self, data: AdminCreateUserInput) -> dict:
        if data.email:
            existing = await self.db.user.find_unique(where={"email": data.email})
            if existing:
                raise HTTPException(status_code=400, detail="Email sudah terdaftar.")
        if data.nim:
            existing = await self.db.user.find_unique(where={"nim": data.nim})
            if existing:
                raise HTTPException(status_code=400, detail="NIM sudah terdaftar.")
        hashed = hash_password(data.password)
        user = await self.db.user.create(
            data={
                "email": data.email or None,
                "nim": data.nim or None,
                "faculty": data.faculty or None,
                "major": data.major or None,
                "password": hashed,
                "full_name": data.full_name,
                "interest": data.interest,
                "email_verified": True if data.email else False,
            }
        )
        return {
            "id": user.id,
            "nim": user.nim,
            "email": user.email,
            "full_name": user.full_name,
            "faculty": user.faculty,
            "major": user.major,
            "interest": user.interest,
            "is_onboarded": user.is_onboarded,
        }

    async def get_stats(self) -> dict:
        total_users, active_projects, total_projects, total_showcases, pending_applications, total_tasks, scraped_competitions = await asyncio.gather(
            self.db.user.count(),
            self.db.project.count(where={"status": {"not": PJ_COMPLETED}}),
            self.db.project.count(),
            self.db.showcase.count(),
            self.db.projectapplication.count(where={"status": APP_PENDING}),
            self.db.task.count(),
            self._count_competitions(),
        )
        return {
            "total_users": total_users,
            "active_projects": active_projects,
            "total_projects": total_projects,
            "total_showcases": total_showcases,
            "pending_applications": pending_applications,
            "total_tasks": total_tasks,
            "scraped_competitions": scraped_competitions,
        }

    async def get_users(self, skip: int, limit: int) -> tuple[list, int]:
        users = await self.db.user.find_many(
            skip=skip,
            take=limit,
            order={"created_at": "desc"},
        )
        total = await self.db.user.count()
        return users, total

    async def get_projects(self, skip: int, limit: int) -> tuple[list, int]:
        projects = await self.db.project.find_many(
            skip=skip,
            take=limit,
            include={
                "owner": True,
                "members": {"include": {"user": True}},
                "applications": {"include": {"applicant": True}},
                "tasks": True,
            },
            order={"created_at": "desc"},
        )
        total = await self.db.project.count()
        return projects, total

    async def get_showcases(self, skip: int, limit: int) -> tuple[list, int]:
        showcases = await self.db.showcase.find_many(
            skip=skip,
            take=limit,
            include={
                "author": True,
                "project": True,
                "likes": {"include": {"user": True}},
                "comments": {
                    "include": {"user": True, "replies": {"include": {"user": True}}}
                },
            },
            order={"created_at": "desc"},
        )
        total = await self.db.showcase.count()
        return showcases, total

    async def get_tasks(self, skip: int, limit: int) -> tuple[list, int]:
        tasks = await self.db.task.find_many(
            skip=skip,
            take=limit,
            include={"project": True, "assignees": {"include": {"user": True}}},
            order={"created_at": "desc"},
        )
        total = await self.db.task.count()
        return tasks, total

    async def get_applications(self, skip: int, limit: int) -> tuple[list, int]:
        applications = await self.db.projectapplication.find_many(
            skip=skip,
            take=limit,
            include={"project": True, "applicant": True},
            order={"applied_at": "desc"},
        )
        total = await self.db.projectapplication.count()
        return applications, total

    async def get_competitions(self, limit: int) -> tuple[list, int]:
        try:
            coll = get_competition_collection()
            cursor = coll.find({}).limit(limit)
            recent_data = await cursor.to_list(length=None)
            for item in recent_data:
                item["_id"] = str(item["_id"])
            return recent_data, len(recent_data)
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to fetch competitions: {str(e)}")

    async def import_users(self, users: list, default_password: str) -> dict:
        hashed = hash_password(default_password)
        success_count = 0
        errors = []
        imported = []
        for i, item in enumerate(users):
            try:
                existing_nim = await self.db.user.find_unique(where={"nim": item.nim})
                if existing_nim:
                    errors.append({"row": i + 1, "nim": item.nim, "message": "NIM sudah terdaftar"})
                    continue
                user = await self.db.user.create(
                    data={
                        "nim": item.nim,
                        "full_name": item.full_name,
                        "faculty": item.faculty,
                        "major": item.major,
                        "interest": item.interest or None,
                        "password": hashed,
                        "email_verified": True,
                    }
                )
                success_count += 1
                imported.append({
                    "nim": user.nim,
                    "full_name": user.full_name,
                    "faculty": user.faculty,
                    "major": user.major,
                })
            except Exception as e:
                errors.append({"row": i + 1, "nim": item.nim, "message": str(e)})
        return {
            "success_count": success_count,
            "total": len(users),
            "errors": errors,
            "imported": imported,
        }

    async def delete_user(self, user_id: str):
        try:
            await self.db.user.delete(where={"id": user_id})
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_project(self, project_id: str):
        try:
            await self.db.project.delete(where={"id": project_id})
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_showcase(self, showcase_id: str):
        try:
            await self.db.showcase.delete(where={"id": showcase_id})
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_task(self, task_id: str):
        try:
            await self.db.task.delete(where={"id": task_id})
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_application(self, application_id: str):
        try:
            await self.db.projectapplication.delete(where={"id": application_id})
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_competition(self, competition_id: str) -> bool:
        try:
            from bson.objectid import ObjectId
            coll = get_competition_collection()
            result = await coll.delete_one({"_id": ObjectId(competition_id)})
            return result.deleted_count > 0
        except Exception:
            return False

    async def get_analytics(self, start_date: str | None, end_date: str | None, faculty: str | None, category: str | None, granularity: str) -> dict:
        fmt = "YYYY-MM" if granularity == "monthly" else ("YYYY-MM-DD" if granularity == "daily" else "IYYY\"-\"IW")
        if granularity == "yearly":
            fmt = "YYYY"

        # ── Build filter clauses per query group ──
        def build_where(params: list, *clauses: tuple[str, str]) -> str:
            where = ""
            for col, val in clauses:
                if val:
                    where += f" AND {col} = ${len(params) + 1}"
                    params.append(val)
            return where

        user_p, user_w = [], ""
        if start_date:
            user_w += f" AND created_at >= ${len(user_p) + 1}::date"
            user_p.append(start_date)
        if end_date:
            user_w += f" AND created_at <= ${len(user_p) + 1}::date"
            user_p.append(end_date)
        if faculty:
            user_w += f" AND faculty = ${len(user_p) + 1}"
            user_p.append(faculty)

        proj_p, proj_w, proj_j = [], "", ""
        if start_date:
            proj_w += f" AND p.created_at >= ${len(proj_p) + 1}::date"
            proj_p.append(start_date)
        if end_date:
            proj_w += f" AND p.created_at <= ${len(proj_p) + 1}::date"
            proj_p.append(end_date)
        if category:
            proj_w += f" AND p.category = ${len(proj_p) + 1}"
            proj_p.append(category)
        if faculty:
            proj_j = ' JOIN "User" u_own ON u_own.id = p.owner_id'
            proj_w += f" AND u_own.faculty = ${len(proj_p) + 1}"
            proj_p.append(faculty)

        task_p, task_w, task_j = [], "", ""
        if start_date:
            task_w += f" AND p.created_at >= ${len(task_p) + 1}::date"
            task_p.append(start_date)
        if end_date:
            task_w += f" AND p.created_at <= ${len(task_p) + 1}::date"
            task_p.append(end_date)
        if category:
            task_w += f" AND p.category = ${len(task_p) + 1}"
            task_p.append(category)
        if faculty:
            task_j = ' JOIN "User" u_ta ON u_ta.id = ta.user_id'
            task_w += f" AND u_ta.faculty = ${len(task_p) + 1}"
            task_p.append(faculty)

        show_p, show_w = [], ""
        if start_date:
            show_w += f" AND s.created_at >= ${len(show_p) + 1}::date"
            show_p.append(start_date)
        if end_date:
            show_w += f" AND s.created_at <= ${len(show_p) + 1}::date"
            show_p.append(end_date)
        if faculty:
            show_w += f" AND u.faculty = ${len(show_p) + 1}"
            show_p.append(faculty)

        # ── 7 queries total, all run in parallel ──
        user_regs_q = self.db.query_raw(
            f"""SELECT to_char(created_at, '{fmt}') AS period, COUNT(*)::int AS total,
                SUM(COUNT(*)) OVER ()::int AS grand_total
                FROM "User" WHERE 1=1{user_w} GROUP BY period ORDER BY period""",
            *user_p,
        )
        users_by_fac_q = self.db.query_raw(
            f"""SELECT faculty, COUNT(*)::int AS total
                FROM "User" WHERE faculty IS NOT NULL{user_w} GROUP BY faculty ORDER BY total DESC""",
            *user_p,
        )
        proj_creations_q = self.db.query_raw(
            f"""SELECT to_char(p.created_at, '{fmt}') AS period, COUNT(*)::int AS total,
                SUM(COUNT(*)) OVER ()::int AS grand_total
                FROM "Project" p{proj_j} WHERE 1=1{proj_w} GROUP BY period ORDER BY period""",
            *proj_p,
        )
        proj_by_cat_q = self.db.query_raw(
            f"""SELECT p.category, COUNT(*)::int AS total
                FROM "Project" p{proj_j} WHERE p.category IS NOT NULL{proj_w} GROUP BY p.category ORDER BY total DESC""",
            *proj_p,
        )
        proj_by_status_q = self.db.query_raw(
            f"""SELECT p.status, COUNT(*)::int AS total
                FROM "Project" p{proj_j} WHERE 1=1{proj_w} GROUP BY p.status""",
            *proj_p,
        )
        task_dist_q = self.db.query_raw(
            f"""SELECT t.status, COUNT(*)::int AS total
                FROM "Task" t
                JOIN "TaskAssignee" ta ON ta.task_id = t.id
                JOIN "Project" p ON p.id = t.project_id{task_j}
                WHERE 1=1{task_w}
                GROUP BY t.status""",
            *task_p,
        )
        showcase_q = self.db.query_raw(
            f"""SELECT
                COALESCE((SELECT COUNT(*)::int FROM "ShowcaseLike" sl
                          JOIN "Showcase" s ON s.id = sl.showcase_id
                          LEFT JOIN "User" u ON u.id = s.author_id WHERE 1=1{show_w}), 0) AS total_likes,
                COALESCE((SELECT COUNT(*)::int FROM "ShowcaseComment" sc
                          JOIN "Showcase" s ON s.id = sc.showcase_id
                          LEFT JOIN "User" u ON u.id = s.author_id WHERE 1=1{show_w}), 0) AS total_comments,
                COALESCE((SELECT COUNT(*)::int FROM "Showcase" s
                          LEFT JOIN "User" u ON u.id = s.author_id WHERE 1=1{show_w}), 0) AS total_showcases""",
            *show_p,
        )
        faculties_q = self.db.query_raw(
            """SELECT DISTINCT faculty FROM "User" WHERE faculty IS NOT NULL AND faculty != '' ORDER BY faculty""",
        )
        categories_q = self.db.query_raw(
            """SELECT DISTINCT category FROM "Project" WHERE category IS NOT NULL AND category != '' ORDER BY category""",
        )

        (user_regs, users_by_faculty, proj_creations, proj_by_cat, proj_by_status,
         task_dist, showcase_res, fac_raw, cat_raw) = await asyncio.gather(
            user_regs_q, users_by_fac_q, proj_creations_q, proj_by_cat_q, proj_by_status_q,
            task_dist_q, showcase_q, faculties_q, categories_q,
        )

        total_users = user_regs[0]["grand_total"] if user_regs else 0
        total_projects = proj_creations[0]["grand_total"] if proj_creations else 0
        showcase_res = showcase_res[0] if showcase_res else {}
        available_faculties = [r["faculty"] for r in (fac_raw or [])]
        available_categories = [r["category"] for r in (cat_raw or [])]

        return {
            "user_registrations": user_regs or [],
            "project_creations": proj_creations or [],
            "users_by_faculty": users_by_faculty or [],
            "projects_by_category": proj_by_cat or [],
            "projects_by_status": proj_by_status or [],
            "task_distribution": task_dist or [],
            "showcase_engagement": {
                "total_likes": showcase_res.get("total_likes", 0),
                "total_comments": showcase_res.get("total_comments", 0),
                "total_showcases": showcase_res.get("total_showcases", 0),
            },
            "total_users": total_users,
            "total_projects": total_projects,
            "available_faculties": available_faculties,
            "available_categories": available_categories,
        }

    async def _count_competitions(self) -> int:
        try:
            coll = get_competition_collection()
            return await coll.count_documents({})
        except Exception:
            return 0
