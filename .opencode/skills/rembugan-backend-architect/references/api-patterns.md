# API Patterns Reference — Response, Error, Pagination

## Global Response Helpers

Buat file `app/core/response.py`:

```python
from typing import Any

def response_success(
    data: Any = None,
    message: str = "success",
    status: str = "success",
) -> dict:
    result = {"status": status, "message": message}
    if data is not None:
        result["data"] = data
    return result


def response_error(
    detail: str,
    status: str = "error",
) -> dict:
    return {"status": status, "detail": detail}


def response_paginated(
    data: list,
    total: int,
    page: int,
    limit: int,
) -> dict:
    return {
        "status": "success",
        "page": page,
        "limit": limit,
        "total": total,
        "has_next": (page * limit) < total,
        "data": data,
    }
```

### Sebelum (❌ manual di tiap route)

```python
return {
    "status": "success",
    "data": {"id": p.id, "title": p.title},
    "page": page,
    "limit": limit,
    "total_projects_available": total_available,
}
```

### Sesudah (✅ konsisten)

```python
return response_success(project_data)
return response_paginated(projects, total, page, limit)
return response_error("Proyek tidak ditemukan.")
```

## Global Exception Handler

Di `app/main.py` — replace scattered try/except:

```python
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content=response_error(exc.detail),
        headers=getattr(exc, "headers", None),
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error(f"Unhandled error: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content=response_error("Terjadi kesalahan internal server."),
    )
```

Dengan ini, route cukup:

```python
if not user:
    raise HTTPException(status_code=404, detail="User tidak ditemukan.")
# No need for try/except — global handler takes care
```

## Pagination Pattern

### Pagination helper di DB level (bukan memory):

```python
# app/core/pagination.py
from dataclasses import dataclass

@dataclass
class PageParams:
    page: int = 1
    limit: int = 10

    @property
    def skip(self) -> int:
        return (self.page - 1) * self.limit

    @property
    def take(self) -> int:
        return self.limit
```

### Usage:

```python
@router.get("/explore")
async def explore(
    page_params: PageParams = Depends(),
    service: ProjectService = Depends(ProjectService),
):
    result = await service.get_explore(user_id, page_params)
    return response_paginated(**result)
```

### Service:

```python
async def get_explore(self, user_id: str, page: PageParams) -> dict:
    total = await self.db.project.count(where={"status": "open", "owner_id": {"not": user_id}})

    projects = await self.db.project.find_many(
        where={"status": "open", "owner_id": {"not": user_id}},
        skip=page.skip,
        take=page.take,
        order={"created_at": "desc"},
    )

    scored = [self._score(p) for p in projects]
    scored.sort(key=lambda x: x["match_score"], reverse=True)

    return {"data": scored, "total": total, "page": page.page, "limit": page.limit}
```

Catatan: scoring tetap di Python sampai pgvector implemented. Tapi fetch & pagination sudah di DB.

## Pydantic V2 Patterns

```python
from pydantic import BaseModel, field_validator, model_config
from typing import Optional

class ProjectCreate(BaseModel):
    model_config = model_config(str_strip_whitespace=True)

    title: str
    description: str
    required_skills: list[str] = []
    total_slots: int | None = None

    @field_validator("title")
    @classmethod
    def title_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("Title tidak boleh kosong")
        return v.strip()
```

Gunakan `int | None` instead of `Optional[int]` — Python 3.10+ style.
