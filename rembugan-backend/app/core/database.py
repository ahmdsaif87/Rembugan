import os
import asyncio
from prisma import Prisma

_DATABASE_URL = os.getenv("DATABASE_URL", "")

# Pastikan pakai pooled URL untuk Neon & tambah param penting
if "neon.tech" in _DATABASE_URL and "-pooler" not in _DATABASE_URL:
    _DATABASE_URL = _DATABASE_URL.replace(".neon.tech", "-pooler.neon.tech")
if "neon.tech" in _DATABASE_URL and "pgbouncer=true" not in _DATABASE_URL:
    sep = "&" if "?" in _DATABASE_URL else "?"
    _DATABASE_URL = f"{_DATABASE_URL}{sep}pgbouncer=true&connection_limit=5&pool_timeout=20"
if "sslmode" not in _DATABASE_URL:
    sep = "&" if "?" in _DATABASE_URL else "?"
    _DATABASE_URL = f"{_DATABASE_URL}{sep}sslmode=require"

os.environ["DATABASE_URL"] = _DATABASE_URL

# Singleton instance — pool size dibatasi biar nggak overload Neon free (max 5)
db = Prisma(pool_size=5)

async def get_db() -> Prisma:
    return db


async def connect_db_with_retry(retries: int = 3, delay: float = 2.0):
    for attempt in range(retries):
        try:
            await db.connect()
            return
        except Exception as e:
            if attempt < retries - 1:
                await asyncio.sleep(delay * (attempt + 1))
            else:
                raise
