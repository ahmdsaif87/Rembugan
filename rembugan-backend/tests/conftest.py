import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock, MagicMock

from app.main import app
from app.core.database import get_db
from app.core.security import verify_token


# ==========================================
# 1. MOCK DATABASE (Prisma)
# ==========================================
@pytest_asyncio.fixture
async def mock_db():
    """Mock Prisma Client — semua operasi DB disimulasikan."""
    db_mock = AsyncMock()

    db_mock.user = AsyncMock()
    db_mock.project = AsyncMock()
    db_mock.projectapplication = AsyncMock()
    db_mock.projectmember = AsyncMock()
    db_mock.task = AsyncMock()
    db_mock.message = AsyncMock()
    db_mock.showcase = AsyncMock()
    db_mock.skill = AsyncMock()
    db_mock.userskill = AsyncMock()

    return db_mock


# ==========================================
# 2. MOCK TOKEN VERIFIER (Unified)
# ==========================================
def mock_verify_token():
    """Simulasi token yang sudah di-decode (JWT atau Firebase)."""
    return {
        "uid": "test_uid_123",
        "email": "test@example.com"
    }


# ==========================================
# 3. TEST CLIENT & DEPENDENCY OVERRIDES
# ==========================================
@pytest.fixture
def client(mock_db):
    """TestClient dengan dependency yang sudah di-override."""
    app.dependency_overrides[get_db] = lambda: mock_db
    app.dependency_overrides[verify_token] = mock_verify_token

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
