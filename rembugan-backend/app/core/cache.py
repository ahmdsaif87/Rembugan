import time
from typing import Any


TTL_EXPLORE = 300  # 5 menit


class MemoryCache:
    """Simple in-memory cache dengan TTL — fallback jika ga ada Redis."""

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

    def set(self, key: str, value: Any, ttl: int = TTL_EXPLORE):
        self._store[key] = (time.time() + ttl, value)

    def invalidate(self, pattern: str = ""):
        if not pattern:
            self._store.clear()
        else:
            self._store = {
                k: v for k, v in self._store.items()
                if pattern not in k
            }


cache = MemoryCache()
