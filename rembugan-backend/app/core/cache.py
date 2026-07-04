import os
import json
import time
import asyncio
from typing import Any
from app.core.logger import get_logger

logger = get_logger(__name__)

TTL_EXPLORE = 300
TTL_DEFAULT = 60


class RedisCache:
    def __init__(self):
        self._redis = None
        self._connected = False

    async def init(self):
        url = os.getenv("REDIS_URL")
        if not url:
            logger.warning("REDIS_URL tidak diset — fallback ke MemoryCache")
            self._connected = False
            return
        try:
            import redis.asyncio as aioredis
            self._redis = aioredis.from_url(url, decode_responses=True, socket_connect_timeout=3)
            await self._redis.ping()
            self._connected = True
            logger.info("Redis terhubung!")
        except Exception as e:
            logger.warning(f"Redis gagal connect ({e}) — fallback ke MemoryCache")
            self._connected = False

    async def disconnect(self):
        if self._redis:
            await self._redis.close()

    async def get(self, key: str) -> Any | None:
        if not self._connected:
            return None
        try:
            val = await self._redis.get(key)
            if val is None:
                return None
            return json.loads(val)
        except Exception as e:
            logger.warning(f"Redis get error: {e}")
            return None

    async def set(self, key: str, value: Any, ttl: int = TTL_DEFAULT):
        if not self._connected:
            return
        try:
            await self._redis.setex(key, ttl, json.dumps(value))
        except Exception as e:
            logger.warning(f"Redis set error: {e}")

    async def invalidate(self, pattern: str = ""):
        if not self._connected:
            return
        try:
            if not pattern:
                await self._redis.flushdb()
            else:
                cursor = 0
                while True:
                    cursor, keys = await self._redis.scan(cursor=cursor, match=f"*{pattern}*")
                    if keys:
                        await self._redis.delete(*keys)
                    if cursor == 0:
                        break
        except Exception as e:
            logger.warning(f"Redis invalidate error: {e}")

    def is_connected(self) -> bool:
        return self._connected


class MemoryCache:
    def __init__(self):
        self._store: dict[str, tuple[float, Any]] = {}

    def get(self, key: str) -> Any | None:
        entry = self._store.get(key)
        if entry is None:
            return None
        expires_at, value = entry
        if time.time() > expires_at:
            del self._store[key]
            return None
        return value

    def set(self, key: str, value: Any, ttl: int = TTL_DEFAULT):
        self._store[key] = (time.time() + ttl, value)

    def invalidate(self, pattern: str = ""):
        if not pattern:
            self._store.clear()
        else:
            self._store = {k: v for k, v in self._store.items() if pattern not in k}

    def is_connected(self) -> bool:
        return True


class Cache:
    def __init__(self):
        self._redis = RedisCache()
        self._memory = MemoryCache()
        self._use_redis = False

    async def init(self):
        await self._redis.init()
        self._use_redis = self._redis.is_connected()

    async def disconnect(self):
        await self._redis.disconnect()

    async def get(self, key: str) -> Any | None:
        if self._use_redis:
            val = await self._redis.get(key)
            if val is not None:
                return val
        return self._memory.get(key)

    async def set(self, key: str, value: Any, ttl: int = TTL_DEFAULT):
        if self._use_redis:
            await self._redis.set(key, value, ttl)
        self._memory.set(key, value, ttl)

    async def invalidate(self, pattern: str = ""):
        if self._use_redis:
            await self._redis.invalidate(pattern)
        self._memory.invalidate(pattern)

    def stats(self) -> dict:
        return {
            "backend": "redis" if self._use_redis else "memory",
            "redis_connected": self._use_redis,
        }


cache = Cache()
