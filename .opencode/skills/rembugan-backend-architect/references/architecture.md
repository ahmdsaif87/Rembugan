# Architecture Reference — Rembugan Backend

## Service Layer Pattern

Route handler hanya bertugas: validasi input + panggil service + return response. **Boleh tidak boleh** ada Prisma query langsung di route.

### Current (❌ Jangan)

```python
# app/api/projects.py
@router.get("/{project_id}")
async def get_project_detail(project_id: int, db: Prisma = Depends(get_db)):
    project = await db.project.find_unique(
        where={"id": project_id},
        include={"owner": True, "members": {"include": {"user": True}}},
    )
    if not project:
        raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")

    members = []
    for m in project.members:
        members.append({"id": m.id, "user_id": m.user_id, "name": m.user.full_name})

    return {"status": "success", "data": {"title": project.title, "members": members}}
```

### Target (✅ Pakai)

```python
# app/services/project_service.py
from dataclasses import dataclass
from prisma import Prisma
from app.core.database import get_db
from app.services.base import BaseService

@dataclass
class ProjectService(BaseService[models.Project]):
    async def get_detail(self, project_id: int) -> dict:
        project = await self.db.project.find_unique(
            where={"id": project_id},
            include={"owner": True, "members": {"include": {"user": True}}},
        )
        if not project:
            raise HTTPException(status_code=404, detail="Proyek tidak ditemukan.")
        return self._format_detail(project)

    def _format_detail(self, project) -> dict:
        return {
            "title": project.title,
            "members": [{"id": m.id, "name": m.user.full_name} for m in (project.members or [])],
            "owner": project.owner.full_name,
        }

# app/api/projects.py — jadi tipis
@router.get("/{project_id}")
async def get_project_detail(project_id: int, service: ProjectService = Depends(ProjectService)):
    data = await service.get_detail(project_id)
    return response_success(data)
```

## Repository Pattern (Opsional, untuk kompleksitas tinggi)

Gunakan repository layer jika query sudah sangat kompleks atau butuh reuse antar service:

```python
# app/repositories/project_repo.py
@dataclass
class ProjectRepository:
    db: Prisma

    async def find_open_excluding(self, user_id: str, exclude_ids: list[int]) -> list:
        return await self.db.project.find_many(
            where={"status": "open", "owner_id": {"not": user_id}},
            order={"created_at": "desc"},
            take=EXPLORE_MAX_ROWS,
        )

# app/services/project_service.py
@dataclass
class ProjectService:
    db: Prisma = Depends(get_db)
    repo: ProjectRepository = Depends(ProjectRepository)

    async def get_explore(self, user_id: str, page: int, limit: int) -> dict:
        projects = await self.repo.find_open_excluding(user_id, [])
        return self._score_and_paginate(projects, user_id, page, limit)
```

## File Structure Standard

```
app/
├── api/              # Route handlers — tipis, hanya orchestrate
│   ├── projects.py
│   ├── auth.py
│   └── ...
├── services/         # Business logic — fat
│   ├── base.py       # BaseService dengan db injection
│   ├── project_service.py
│   ├── user_service.py
│   ├── auth_service.py
│   └── ...
├── repositories/     # (opsional) Data access — jika query complex
│   ├── project_repo.py
│   └── ...
├── core/
│   ├── database.py   # db = Prisma()
│   ├── response.py   # response_success, response_error helpers
│   └── ...
├── schemas/          # Pydantic models
└── main.py
```

## BaseService Template

```python
# app/services/base.py
from dataclasses import dataclass
from fastapi import Depends
from prisma import Prisma
from app.core.database import get_db

@dataclass
class BaseService:
    db: Prisma = Depends(get_db)
```

Semua service inherit dari `BaseService` untuk dapat `self.db` otomatis via DI.
