import os
import re
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    async_sessionmaker,
    AsyncSession,
)
from sqlalchemy.orm import DeclarativeBase

# Baca raw dari file .env langsung, hindari Prisma yang udah modif env
_env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), ".env")
_DATABASE_URL = os.getenv("DATABASE_URL", "")
if not _DATABASE_URL and os.path.exists(_env_path):
    with open(_env_path) as f:
        for line in f:
            line = line.strip()
            if line.startswith("DATABASE_URL="):
                raw = line.split("=", 1)[1].strip().strip("\"'")
                _DATABASE_URL = raw
                break

# Prisma pakai `postgresql://`, SQLAlchemy async butuh `postgresql+asyncpg://`
_ASYNC_URL = _DATABASE_URL.replace("postgresql://", "postgresql+asyncpg://", 1)
# Hapus params yang gak didukung asyncpg
_ASYNC_URL = re.sub(r"&?(sslmode|channel_binding|pgbouncer|connection_limit|pool_timeout|connect_timeout)=[^&]*", "", _ASYNC_URL)
# Tambah SSL config
_ASYNC_URL += "&ssl=require" if "?" in _ASYNC_URL else "?ssl=require"

engine = create_async_engine(_ASYNC_URL, echo=False, pool_size=5, max_overflow=10)

async_session_factory = async_sessionmaker(engine, expire_on_commit=False)


class Base(DeclarativeBase):
    pass


async def get_db_session():
    async with async_session_factory() as session:
        yield session


async def close_engine():
    await engine.dispose()
