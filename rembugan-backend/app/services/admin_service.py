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

    async def _count_competitions(self) -> int:
        try:
            coll = get_competition_collection()
            return await coll.count_documents({})
        except Exception:
            return 0
