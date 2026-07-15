import asyncio
from datetime import datetime, timezone
from fastapi import Depends, HTTPException
from sqlalchemy import select, func, text
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database_sql import get_db_session
from app.core.security import hash_password
from app.schemas.auth import AdminCreateUserInput, AdminResetPasswordInput, ImportUsersInput
from app.core.constants import PJ_COMPLETED, APP_PENDING
from app.models import User
from app.models.social import Showcase, ShowcaseLike, ShowcaseComment, ProjectFile
from app.models.collaboration import Project, ProjectMember, ProjectApplication, Task, TaskAssignee
from app.services.competitions import get_competition_collection


class AdminService:
    def __init__(self, session: AsyncSession = Depends(get_db_session)):
        self.session = session

    async def reset_user_password(self, nim: str, new_password: str):
        result = await self.session.execute(select(User).where(User.nim == nim))
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(status_code=404, detail="User dengan NIM tersebut tidak ditemukan.")
        user.password = hash_password(new_password)
        await self.session.commit()

    async def create_user(self, data: AdminCreateUserInput) -> dict:
        if data.email:
            result = await self.session.execute(select(User).where(User.email == data.email))
            if result.scalar_one_or_none():
                raise HTTPException(status_code=400, detail="Email sudah terdaftar.")
        if data.nim:
            result = await self.session.execute(select(User).where(User.nim == data.nim))
            if result.scalar_one_or_none():
                raise HTTPException(status_code=400, detail="NIM sudah terdaftar.")
        hashed = hash_password(data.password)
        now = datetime.now(timezone.utc)
        user = User(
            email=data.email or None,
            nim=data.nim or None,
            faculty=data.faculty or None,
            major=data.major or None,
            password=hashed,
            full_name=data.full_name,
            interest=data.interest,
            email_verified=True if data.email else False,
            created_at=now,
            updated_at=now,
        )
        self.session.add(user)
        await self.session.commit()
        await self.session.refresh(user)
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
        async def count_users():
            result = await self.session.execute(select(func.count(User.id)))
            return result.scalar() or 0

        async def count_active_projects():
            result = await self.session.execute(
                select(func.count(Project.id)).where(Project.status != PJ_COMPLETED)
            )
            return result.scalar() or 0

        async def count_total_projects():
            result = await self.session.execute(select(func.count(Project.id)))
            return result.scalar() or 0

        async def count_showcases():
            result = await self.session.execute(select(func.count(Showcase.id)))
            return result.scalar() or 0

        async def count_pending_apps():
            result = await self.session.execute(
                select(func.count(ProjectApplication.id)).where(ProjectApplication.status == APP_PENDING)
            )
            return result.scalar() or 0

        async def count_tasks():
            result = await self.session.execute(select(func.count(Task.id)))
            return result.scalar() or 0

        total_users, active_projects, total_projects, total_showcases, pending_applications, total_tasks = await asyncio.gather(
            count_users(),
            count_active_projects(),
            count_total_projects(),
            count_showcases(),
            count_pending_apps(),
            count_tasks(),
        )
        scraped_competitions = await self._count_competitions()
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
        result = await self.session.execute(
            select(User).order_by(User.created_at.desc()).offset(skip).limit(limit)
        )
        users = result.scalars().all()
        total_result = await self.session.execute(select(func.count(User.id)))
        total = total_result.scalar() or 0
        return users, total

    async def get_projects(self, skip: int, limit: int) -> tuple[list, int]:
        result = await self.session.execute(
            select(Project).order_by(Project.created_at.desc()).offset(skip).limit(limit)
        )
        projects = result.scalars().all()
        total_result = await self.session.execute(select(func.count(Project.id)))
        total = total_result.scalar() or 0
        return projects, total

    async def get_showcases(self, skip: int, limit: int) -> tuple[list, int]:
        result = await self.session.execute(
            select(Showcase).order_by(Showcase.created_at.desc()).offset(skip).limit(limit)
        )
        showcases = result.scalars().all()
        total_result = await self.session.execute(select(func.count(Showcase.id)))
        total = total_result.scalar() or 0
        return showcases, total

    async def get_tasks(self, skip: int, limit: int) -> tuple[list, int]:
        result = await self.session.execute(
            select(Task).order_by(Task.created_at.desc()).offset(skip).limit(limit)
        )
        tasks = result.scalars().all()
        total_result = await self.session.execute(select(func.count(Task.id)))
        total = total_result.scalar() or 0
        return tasks, total

    async def get_applications(self, skip: int, limit: int) -> tuple[list, int]:
        result = await self.session.execute(
            select(ProjectApplication).order_by(ProjectApplication.applied_at.desc()).offset(skip).limit(limit)
        )
        applications = result.scalars().all()
        total_result = await self.session.execute(select(func.count(ProjectApplication.id)))
        total = total_result.scalar() or 0
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
                result = await self.session.execute(select(User).where(User.nim == item.nim))
                if result.scalar_one_or_none():
                    errors.append({"row": i + 1, "nim": item.nim, "message": "NIM sudah terdaftar"})
                    continue
                now = datetime.now(timezone.utc)
                user = User(
                    nim=item.nim,
                    full_name=item.full_name,
                    faculty=item.faculty,
                    major=item.major,
                    interest=item.interest or None,
                    password=hashed,
                    email_verified=True,
                    created_at=now,
                    updated_at=now,
                )
                self.session.add(user)
                await self.session.commit()
                await self.session.refresh(user)
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
            result = await self.session.execute(select(User).where(User.id == user_id))
            user = result.scalar_one_or_none()
            if not user:
                raise HTTPException(status_code=404, detail="User tidak ditemukan")
            await self.session.delete(user)
            await self.session.commit()
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_project(self, project_id: str):
        try:
            result = await self.session.execute(select(Project).where(Project.id == int(project_id)))
            project = result.scalar_one_or_none()
            if not project:
                raise HTTPException(status_code=404, detail="Project tidak ditemukan")
            await self.session.delete(project)
            await self.session.commit()
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_showcase(self, showcase_id: str):
        try:
            result = await self.session.execute(select(Showcase).where(Showcase.id == showcase_id))
            showcase = result.scalar_one_or_none()
            if not showcase:
                raise HTTPException(status_code=404, detail="Showcase tidak ditemukan")
            await self.session.delete(showcase)
            await self.session.commit()
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_task(self, task_id: str):
        try:
            result = await self.session.execute(select(Task).where(Task.id == int(task_id)))
            task = result.scalar_one_or_none()
            if not task:
                raise HTTPException(status_code=404, detail="Task tidak ditemukan")
            await self.session.delete(task)
            await self.session.commit()
        except Exception as e:
            raise HTTPException(status_code=400, detail=str(e))

    async def delete_application(self, application_id: str):
        try:
            result = await self.session.execute(
                select(ProjectApplication).where(ProjectApplication.id == int(application_id))
            )
            app = result.scalar_one_or_none()
            if not app:
                raise HTTPException(status_code=404, detail="Application tidak ditemukan")
            await self.session.delete(app)
            await self.session.commit()
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

        user_p, user_w = [], ""
        if start_date:
            user_w += f" AND created_at >= :u{len(user_p)}::date"
            user_p.append(start_date)
        if end_date:
            user_w += f" AND created_at <= :u{len(user_p)}::date"
            user_p.append(end_date)
        if faculty:
            user_w += f" AND faculty = :u{len(user_p)}"
            user_p.append(faculty)

        proj_p, proj_w, proj_j = [], "", ""
        if start_date:
            proj_w += f" AND p.created_at >= :pj{len(proj_p)}::date"
            proj_p.append(start_date)
        if end_date:
            proj_w += f" AND p.created_at <= :pj{len(proj_p)}::date"
            proj_p.append(end_date)
        if category:
            proj_w += f" AND p.category = :pj{len(proj_p)}"
            proj_p.append(category)
        if faculty:
            proj_j = ' JOIN "User" u_own ON u_own.id = p.owner_id'
            proj_w += f" AND u_own.faculty = :pj{len(proj_p)}"
            proj_p.append(faculty)

        task_p, task_w, task_j = [], "", ""
        if start_date:
            task_w += f" AND p.created_at >= :t{len(task_p)}::date"
            task_p.append(start_date)
        if end_date:
            task_w += f" AND p.created_at <= :t{len(task_p)}::date"
            task_p.append(end_date)
        if category:
            task_w += f" AND p.category = :t{len(task_p)}"
            task_p.append(category)
        if faculty:
            task_j = ' JOIN "User" u_ta ON u_ta.id = ta.user_id'
            task_w += f" AND u_ta.faculty = :t{len(task_p)}"
            task_p.append(faculty)

        show_p, show_w = [], ""
        if start_date:
            show_w += f" AND s.created_at >= :s{len(show_p)}::date"
            show_p.append(start_date)
        if end_date:
            show_w += f" AND s.created_at <= :s{len(show_p)}::date"
            show_p.append(end_date)
        if faculty:
            show_w += f" AND u.faculty = :s{len(show_p)}"
            show_p.append(faculty)

        user_dict = {f"u{i}": v for i, v in enumerate(user_p)}
        proj_dict = {f"pj{i}": v for i, v in enumerate(proj_p)}
        task_dict = {f"t{i}": v for i, v in enumerate(task_p)}
        show_dict = {f"s{i}": v for i, v in enumerate(show_p)}

        user_regs_q = self.session.execute(
            text(f"""SELECT to_char(created_at, '{fmt}') AS period, COUNT(*)::int AS total,
                SUM(COUNT(*)) OVER ()::int AS grand_total
                FROM "User" WHERE 1=1{user_w} GROUP BY period ORDER BY period"""),
            user_dict or None,
        )
        users_by_fac_q = self.session.execute(
            text(f"""SELECT faculty, COUNT(*)::int AS total
                FROM "User" WHERE faculty IS NOT NULL{user_w} GROUP BY faculty ORDER BY total DESC"""),
            user_dict or None,
        )
        proj_creations_q = self.session.execute(
            text(f"""SELECT to_char(p.created_at, '{fmt}') AS period, COUNT(*)::int AS total,
                SUM(COUNT(*)) OVER ()::int AS grand_total
                FROM "Project" p{proj_j} WHERE 1=1{proj_w} GROUP BY period ORDER BY period"""),
            proj_dict or None,
        )
        proj_by_cat_q = self.session.execute(
            text(f"""SELECT p.category, COUNT(*)::int AS total
                FROM "Project" p{proj_j} WHERE p.category IS NOT NULL{proj_w} GROUP BY p.category ORDER BY total DESC"""),
            proj_dict or None,
        )
        proj_by_status_q = self.session.execute(
            text(f"""SELECT p.status, COUNT(*)::int AS total
                FROM "Project" p{proj_j} WHERE 1=1{proj_w} GROUP BY p.status"""),
            proj_dict or None,
        )
        task_dist_q = self.session.execute(
            text(f"""SELECT t.status, COUNT(*)::int AS total
                FROM "Task" t
                JOIN "TaskAssignee" ta ON ta.task_id = t.id
                JOIN "Project" p ON p.id = t.project_id{task_j}
                WHERE 1=1{task_w}
                GROUP BY t.status"""),
            task_dict or None,
        )
        showcase_q = self.session.execute(
            text(f"""SELECT
                COALESCE((SELECT COUNT(*)::int FROM "ShowcaseLike" sl
                          JOIN "Showcase" s ON s.id = sl.showcase_id
                          LEFT JOIN "User" u ON u.id = s.author_id WHERE 1=1{show_w}), 0) AS total_likes,
                COALESCE((SELECT COUNT(*)::int FROM "ShowcaseComment" sc
                          JOIN "Showcase" s ON s.id = sc.showcase_id
                          LEFT JOIN "User" u ON u.id = s.author_id WHERE 1=1{show_w}), 0) AS total_comments,
                COALESCE((SELECT COUNT(*)::int FROM "Showcase" s
                          LEFT JOIN "User" u ON u.id = s.author_id WHERE 1=1{show_w}), 0) AS total_showcases"""),
            show_dict or None,
        )
        faculties_q = self.session.execute(
            text("""SELECT DISTINCT faculty FROM "User" WHERE faculty IS NOT NULL AND faculty != '' ORDER BY faculty"""),
        )
        categories_q = self.session.execute(
            text("""SELECT DISTINCT category FROM "Project" WHERE category IS NOT NULL AND category != '' ORDER BY category"""),
        )

        (user_regs, users_by_faculty, proj_creations, proj_by_cat, proj_by_status,
         task_dist, showcase_res, fac_raw, cat_raw) = await asyncio.gather(
            user_regs_q, users_by_fac_q, proj_creations_q, proj_by_cat_q, proj_by_status_q,
            task_dist_q, showcase_q, faculties_q, categories_q,
        )

        user_regs_list = [{"period": r[0], "total": r[1], "grand_total": r[2]} for r in user_regs.fetchall()] if user_regs else []
        users_by_faculty_list = [{"faculty": r[0], "total": r[1]} for r in users_by_faculty.fetchall()] if users_by_faculty else []
        proj_creations_list = [{"period": r[0], "total": r[1], "grand_total": r[2]} for r in proj_creations.fetchall()] if proj_creations else []
        proj_by_cat_list = [{"category": r[0], "total": r[1]} for r in proj_by_cat.fetchall()] if proj_by_cat else []
        proj_by_status_list = [{"status": r[0], "total": r[1]} for r in proj_by_status.fetchall()] if proj_by_status else []
        task_dist_list = [{"status": r[0], "total": r[1]} for r in task_dist.fetchall()] if task_dist else []
        showcase_row = showcase_res.fetchone() if showcase_res else None
        fac_list = [r[0] for r in fac_raw.fetchall()] if fac_raw else []
        cat_list = [r[0] for r in cat_raw.fetchall()] if cat_raw else []

        total_users = user_regs_list[0]["grand_total"] if user_regs_list else 0
        total_projects = proj_creations_list[0]["grand_total"] if proj_creations_list else 0

        return {
            "user_registrations": user_regs_list,
            "project_creations": proj_creations_list,
            "users_by_faculty": users_by_faculty_list,
            "projects_by_category": proj_by_cat_list,
            "projects_by_status": proj_by_status_list,
            "task_distribution": task_dist_list,
            "showcase_engagement": {
                "total_likes": showcase_row[0] if showcase_row else 0,
                "total_comments": showcase_row[1] if showcase_row else 0,
                "total_showcases": showcase_row[2] if showcase_row else 0,
            },
            "total_users": total_users,
            "total_projects": total_projects,
            "available_faculties": fac_list,
            "available_categories": cat_list,
        }

    async def _count_competitions(self) -> int:
        try:
            coll = get_competition_collection()
            return await coll.count_documents({})
        except Exception:
            return 0

    async def get_privacy_policy(self) -> str:
        try:
            result = await self.session.execute(
                text("SELECT value FROM \"AppSetting\" WHERE key = 'privacy_policy' LIMIT 1")
            )
            row = result.fetchone()
            return row[0] if row else ""
        except Exception:
            return ""

    async def update_privacy_policy(self, content: str):
        try:
            await self.session.execute(
                text("""
                    INSERT INTO "AppSetting" (key, value, updated_at)
                    VALUES ('privacy_policy', :content, NOW())
                    ON CONFLICT (key)
                    DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()
                """),
                {"content": content},
            )
            await self.session.commit()
        except Exception:
            await self.session.execute(
                text("""
                    CREATE TABLE IF NOT EXISTS "AppSetting" (
                        key TEXT PRIMARY KEY,
                        value TEXT NOT NULL DEFAULT '',
                        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                    )
                """)
            )
            await self.session.commit()
            await self.session.execute(
                text("""
                    INSERT INTO "AppSetting" (key, value, updated_at)
                    VALUES ('privacy_policy', :content, NOW())
                    ON CONFLICT (key)
                    DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()
                """),
                {"content": content},
            )
            await self.session.commit()
