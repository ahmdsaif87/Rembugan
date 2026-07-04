# Database Reference — Prisma + PostgreSQL + pgvector

## Prisma Query Best Practices

### Use `select` over `include` when only specific fields needed

```python
# ❌ Ambil semua field padahal cuma butuh owner_id + status
project = await db.project.find_unique(
    where={"id": project_id},
    include={"owner": True},
)

# ✅ Explicit select — lebih cepat, less data transfer
project = await db.project.find_unique(
    where={"id": project_id},
    select={"owner_id": True, "status": True},
)
```

### Batch query instead of loop N+1

```python
# ❌ N+1: Query per project di loop
for p in projects:
    app = await db.projectapplication.find_first(
        where={"project_id": p.id, "applicant_id": uid}
    )

# ✅ Batch: 1 query instead of N
my_apps = await db.projectapplication.find_many(
    where={"applicant_id": uid},
    select={"project_id": True},
)
applied_ids = {a.project_id for a in my_apps}
```

### Prisma `in` filter for bulk lookups

```python
users = await db.user.find_many(
    where={"id": {"in": user_ids}},
    select={"id": True, "full_name": True, "photo_url": True},
)
```

## pgvector Setup

### Migration (via SQL raw atau Prisma migration)

```sql
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE "User" ADD COLUMN embedding_vector vector(384);
ALTER TABLE "Project" ADD COLUMN embedding_vector vector(384);
ALTER TABLE "Showcase" ADD COLUMN embedding_vector vector(384);
```

### Index

```sql
CREATE INDEX ON "User" USING ivfflat (embedding_vector vector_cosine_ops)
    WITH (lists = 100);

CREATE INDEX ON "Project" USING ivfflat (embedding_vector vector_cosine_ops)
    WITH (lists = 100);
```

### Query cosine similarity di SQL (ganti Python loop)

```python
# ❌ Current: fetch all + Python loop
projects = await db.project.find_many(where={"status": "open"})
for p in projects:
    score = cosine_similarity(user_emb, p.embedding)

# ✅ Target: pgvector ORDER BY
results = await db.query_raw(
    """
    SELECT id, title, description,
           1 - (embedding_vector <=> $1::vector) AS match_score
    FROM "Project"
    WHERE status = 'open'
    ORDER BY embedding_vector <=> $1::vector
    LIMIT $2 OFFSET $3
    """,
    user_embedding, limit, offset,
)
```

## Index Strategy

| Query Pattern | Index |
|---|---|
| `WHERE status = 'open' AND owner_id != X` | `(status, owner_id)` |
| `WHERE project_id = X AND status = Y` (tasks) | `(project_id, status)` |
| `WHERE user_id = X ORDER BY created_at DESC` (notif) | `(user_id, is_read, created_at)` |
| `WHERE sender_id = X OR receiver_id = X` (messages) | `(sender_id, created_at)`, `(receiver_id, created_at)` |
| `WHERE project_id = X` (members, apps, tasks) | `(project_id)` |

## Connection Pooling

Di `.env` atau environment:

```
PRISMA_POOL_SIZE=10
PRISMA_POOL_OVERFLOW=5
PRISMA_POOL_TIMEOUT=30
```

Atau via `Prisma()` init:

```python
db = Prisma(
    pool_size=10,
    pool_overflow=5,
    pool_timeout=30,
    connect_timeout=timedelta(seconds=15),
)
```

## Prisma Upgrade Guide (0.15.0 → latest)

1. `pip install --upgrade prisma`
2. `prisma py fetch` (with `PRISMA_CLI_QUERY_ENGINE_TYPE=binary`)
3. `prisma generate`
4. Ganti `db push` ke migration: `prisma migrate dev --name init`
5. Test semua endpoint
6. Update `requirements.txt`
