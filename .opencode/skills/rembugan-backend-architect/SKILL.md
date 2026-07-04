---
name: rembugan-backend-architect
description: "Custom skill untuk maintain dan improve rembugan-backend (FastAPI + Prisma + PostgreSQL + pgvector)"
license: MIT
metadata:
  author: rembugan-team
  version: "1.0.0"
  domain: backend
  triggers: rembugan, backend, Prisma, FastAPI, FastAPI endpoint, service layer, repository, N+1, pgvector, cache, Redis, PostgreSQL, response format, error handling, pagination, migration
  role: architect
  scope: implementation
  output-format: code
---

# Rembugan Backend Architect

Skill khusus untuk maintain & improve `rembugan-backend` — FastAPI + Prisma ORM + PostgreSQL/Neon + pgvector.

## When to Use This Skill

- Membuat endpoint atau route baru
- Refactor route yang campur aduk query + response
- Optimasi query lambat (explore, N+1, pagination di memory)
- Setup caching dengan Redis
- Migrasi ke pgvector untuk similarity search
- Standarisasi response format & error handling
- Upgrade Prisma ORM

## Autoload References

| Context | Reference | Load When |
|---------|-----------|-----------|
| Architecture | `references/architecture.md` | Membuat route baru, refactor route existing, nambah service layer |
| Database | `references/database.md` | Prisma query optimization, pgvector, indexing, migration |
| API Patterns | `references/api-patterns.md` | Response standardization, error handling, pagination |
| Caching | `references/caching.md` | Redis setup, cache strategy, MemoryCache replacement |
| Performance | `references/performance.md` | N+1 detection, DB pagination, profiling |

## Constraints

### MUST DO
- Prisma query HARUS di service layer, jangan di route handler
- Response format wajib konsisten: `{"status": "success", "data": ...}` atau `{"status": "error", "detail": ...}`
- Error handling wajib pake `HTTPException`, jangan return dict
- Pagination wajib di DB level (`skip`/`take`), jangan di memory
- N+1 query wajib di-fix dengan `include` atau batch query
- Type hints wajib di semua fungsi

### MUST NOT DO
- Jangan inline Prisma query di route handler
- Jangan fetch all rows trus slice di Python
- Jangan compare embedding di Python kalau bisa pake pgvector
- Jangan hardcode response dict di tiap route — pake helper
- Jangan skip error handling — every query result must be checked

## Reference Files Detail

### `references/architecture.md`
- Service layer pattern: extract query dari route ke service class
- Repository pattern: abstract Prisma ops dari business logic
- Dependency injection: service + repository via `Depends()`
- Contoh refactor dari code existing (ProjectService, UserService, dll)
- File structure standard: `app/services/{domain}_service.py`

### `references/database.md`
- Prisma query best practices (select, include, batch)
- pgvector setup & query (`ORDER BY embedding <-> ...`)
- Index strategy (composite index untuk query umum)
- Connection pooling tuning
- Prisma upgrade guide (0.15.0 → latest)

### `references/api-patterns.md`
- Global response helper: `response_success()`, `response_error()`, `response_paginated()`
- Global exception handler middleware (ganti try/catch scattered)
- Pagination helper reusable
- Pydantic V2 patterns validasi

### `references/caching.md`
- Redis integration via `redis-py` + FastAPI dependency
- Cache key convention: `{domain}:{action}:{params}`
- TTL strategy per domain (explore=300s, profile=600s, dll)
- Invalidation pattern: on write → delete related keys
- MemoryCache migration path

### `references/performance.md`
- N+1 detection checklist
- DB-level pagination pattern (ganti in-memory slice)
- Async optimization (run_in_executor, proper asyncio)
- Monitoring: response time middleware, query profiling
