from dataclasses import dataclass
from fastapi import Depends
from prisma import Prisma
from app.core.database import get_db


@dataclass
class BaseService:
    db: Prisma = Depends(get_db)
