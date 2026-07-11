from dataclasses import dataclass
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends
from app.core.database_sql import get_db_session


@dataclass
class BaseService:
    session: AsyncSession = Depends(get_db_session)
