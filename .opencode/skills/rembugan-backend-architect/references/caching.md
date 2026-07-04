# Caching Reference — Redis Integration

## Redis Setup

### Install

```bash
pip install redis
```

### Connection di `app/core/cache.py` (replacement for MemoryCache)

```python
import json
from typing import Any
from redis.asyncio import Redis

redis: Redis | None = None


async def init_redis():
    global redis
    redis = Redis.from_url("redis://localhost:6379", decode_responses=True)
    await redis.ping()


async def close_redis():
    global redis
    if redis:
        await redis.close()


class RedisCache:
    """Async Redis cache — drop-in replacement for MemoryCache."""

    def __init__(self, prefix: str = ""):
        self._prefix = prefix

    def _key(self, key: str) -> str:
        return f"{self._prefix}:{key}" if self._prefix else key

    async def get(self, key: str) -> Any | None:
        if not redis:
            return None
        val = await redis.get(self._key(key))
        if val is None:
            return None
        try:
            return json.loads(val)
        except (json.JSONDecodeError, TypeError):
            return val

    async def set(self, key: str, value: Any, ttl: int = 300):
        if not redis:
            return
        await redis.setex(self._key(key), ttl, json.dumps(value, default=str))

    async def delete(self, pattern: str = ""):
        if not redis:
            return
        if pattern:
            keys = await redis.keys(self._key(pattern))
            if keys:
                await redis.delete(*keys)
        else:
            await redis.flushdb()


cache = RedisCache()
```

### Lifecycle di `app/main.py`

```python
from app.core.cache import init_redis, close_redis

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_redis()
    await db.connect()
    yield
    await db.disconnect()
    await close_redis()
```

## FastAPI Dependency

```python
# app/core/dependencies.py
from app.core.cache import RedisCache

async def get_cache() -> RedisCache:
    return RedisCache(prefix="rembugan")
```

## TTL Strategy

| Domain | TTL | Key Pattern |
|--------|-----|-------------|
| Project explore | 300s (5 min) | `explore:{user_id}:{page}:{limit}` |
| Project detail | 600s (10 min) | `project:{id}` |
| User profile | 600s (10 min) | `profile:{user_id}` |
| Showcase feed | 300s (5 min) | `showcase:feed:{page}` |
| User stats | 1800s (30 min) | `user:stats:{user_id}` |

## Invalidation Pattern

Write operations should invalidate related cache keys:

```python
# app/services/project_service.py
async def create_project(self, data, user_id) -> dict:
    project = await self.db.project.create(data={...})
    # Invalidate explore cache (bukan delete 1 key, tapi pola prefix)
    await self.cache.delete("explore:*")
    return format_project(project)

async def update_project(self, project_id: int, data) -> dict:
    project = await self.db.project.update(where={"id": project_id}, data=data)
    await self.cache.delete(f"project:{project_id}")
    await self.cache.delete("explore:*")
    return format_project(project)
```

## Full Usage in Service

```python
@dataclass
class ProjectService:
    db: Prisma = Depends(get_db)
    cache: RedisCache = Depends(get_cache)

    async def get_explore(self, user_id: str, page: PageParams) -> dict:
        cache_key = f"explore:{user_id}:{page.page}:{page.limit}"
        cached = await self.cache.get(cache_key)
        if cached:
            return cached

        result = await self._query_explore(user_id, page)
        await self.cache.set(cache_key, result, ttl=300)
        return result
```

## MemoryCache → Redis Migration Path

1. Tambah `redis` ke `requirements.txt`
2. Copy `RedisCache` class ke `app/core/cache.py`
3. Replace `cache = MemoryCache()` → `cache = RedisCache()`
4. Update lifespan untuk init/close Redis
5. Update service yang pake cache

Selama transisi, bisa dual-write: both MemoryCache + Redis, read from Redis first.
