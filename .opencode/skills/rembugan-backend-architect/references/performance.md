# Performance Reference — N+1, Pagination, Profiling

## N+1 Detection Checklist

N+1 terjadi ketika loop di Python memicu query terpisah per iterasi.

### ❌ Pola N+1

```python
# projects.py — fetch memberships & apps per project di loop
projects = await db.project.find_many(where={...})
for p in projects:
    app = await db.projectapplication.find_first(
        where={"project_id": p.id, "applicant_id": uid}
    )
```

### ✅ Fix

```python
projects = await db.project.find_many(where={...})
# 1 query batch instead of N
my_apps = await db.projectapplication.find_many(
    where={"applicant_id": uid},
    select={"project_id": True},
)
applied_ids = {a.project_id for a in my_apps}
```

### Checklist fix untuk file yang sudah ada:

| File | Line | Issue | Fix |
|------|------|-------|-----|
| `app/api/projects.py` | 147-154 | N+1 apps & memberships per project | Batch query sekali |
| `app/api/projects.py` | 130-138 | Fetch 1000 rows + sort in Python | DB pagination |
| `app/api/projects.py` | 156-191 | Cosine similarity Python loop | pgvector |
| `app/services/embedding.py` | 74-101 | `reembed_*` fungsi individual | Batch reembed |

## DB-Level Pagination

### ❌ Current: fetch all, score, sort, slice di memory

```python
projects = await db.project.find_many(
    where={"status": "open"},
    order={"created_at": "desc"},
    take=EXPLORE_MAX_ROWS,  # 1000
)
# ... scoring loop ...
scored_projects.sort(key=lambda x: x["match_score"], reverse=True)
paginated = scored_projects[start:start + limit]
```

### ✅ Target: paginate sebelum scoring (selagi belum pgvector)

```python
total = await db.project.count(where={"status": "open"})

projects = await db.project.find_many(
    where={"status": "open"},
    skip=0,              # atau berdasarkan page
    take=TARGET_ROWS,    # misal 50 — cukup untuk scoring + pagination
    order={"created_at": "desc"},
)

# Score cuma buat yang di-fetch
scored = [self._score(p, user_skills) for p in projects]
scored.sort(key=lambda x: x["match_score"], reverse=True)

# Paginate final
paginated = scored[skip:skip + limit]

# Note: ini masih compromise — idealnya pgvector biar bisa ORDER BY score di DB
```

### ✅ Ideal: pgvector + DB scoring + DB pagination

```sql
SELECT id, title,
       1 - (embedding <=> $1::vector) AS score
FROM "Project"
WHERE status = 'open' AND owner_id != $2
ORDER BY score DESC
LIMIT $3 OFFSET $4
```

## Async Optimization

### Blocking operations → `run_in_executor`

```python
# Current: sync embedding di async context
def generate(text: str) -> list[float]:
    model = TextEmbedding("BAAI/bge-small-en-v1.5")
    return list(model.embed(text))[0]

async def reembed_user(db, user_id: str):
    loop = asyncio.get_running_loop()
    emb = await loop.run_in_executor(None, generate, txt)

```

### Avoid `asyncio.create_task` fire-and-forget for critical ops

```python
# ❌ Fire-and-forget — error silent
asyncio.create_task(preload_embedding_model())

# ✅ Await or at least log errors
async def preload():
    try:
        await preload_embedding_model()
    except Exception as e:
        logger.error(f"Preload failed: {e}")

task = asyncio.create_task(preload())
task.add_done_callback(lambda t: logger.error(f"Preload crashed: {t.exception()}") if t.exception() else None)
```

## Monitoring & Profiling

### Response time middleware (already exists — `main.py:109`)

```python
response.headers["X-Response-Time-Ms"] = str(int(elapsed))
```

### Query profiling — log slow queries

```python
# app/core/database.py
import time
from prisma import Prisma

class MonitoredPrisma(Prisma):
    async def _execute(self, query, *args, **kwargs):
        start = time.monotonic()
        result = await super()._execute(query, *args, **kwargs)
        elapsed = (time.monotonic() - start) * 1000
        if elapsed > 500:  # slow query threshold > 500ms
            logger.warning(f"Slow query ({elapsed:.0f}ms): {query[:200]}")
        return result
```

### Health check endpoint for cache & DB

```python
@router.get("/healthz")
async def healthz():
    db_ok = False
    cache_ok = False
    try:
        await db.execute_raw("SELECT 1")
        db_ok = True
    except Exception:
        pass
    try:
        await redis.ping()
        cache_ok = True
    except Exception:
        pass

    return {
        "status": "healthy" if db_ok and cache_ok else "degraded",
        "database": "connected" if db_ok else "disconnected",
        "cache": "connected" if cache_ok else "disconnected",
    }
```
