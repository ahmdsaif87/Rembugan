import json
import os
import pytest
from unittest.mock import AsyncMock, MagicMock, PropertyMock, patch
from datetime import datetime, timezone
from typing import AsyncGenerator, Generator
from httpx import ASGITransport, AsyncClient

os.environ["JWT_SECRET_KEY"] = "test-secret-key"
os.environ["MISTRAL_API_KEY"] = "test-mistral-key"
os.environ["GROQ_API_KEY"] = "test-groq-key"
os.environ["MONGO_URI"] = "mongodb://fake:27017"
os.environ["DATABASE_URL"] = "postgresql://fake:5432/test"

TEST_USER_ID = "test-user-uuid-1234"
TEST_USER_EMAIL = "test@example.com"
TEST_USER_FULL_NAME = "Test User"

NOW = datetime.now(timezone.utc)


class MockSkill:
    def __init__(self, id=1, name="Python"):
        self.id = id
        self.name = name


class MockUserSkill:
    def __init__(self, skill_name="Python"):
        self.skill = MockSkill(name=skill_name)


class MockUser:
    def __init__(self, **kwargs):
        defaults = dict(
            id=TEST_USER_ID,
            email=TEST_USER_EMAIL,
            email_verified=True,
            password="$2b$12$hashedpassword",
            full_name=TEST_USER_FULL_NAME,
            nim="1234567890",
            faculty="Fakultas Teknik",
            major="Informatika",
            handle=None,
            bio="A test bio",
            interest="Tech Enthusiast",
            photo_url="https://example.com/photo.jpg",
            cover_url=None,
            social_links=None,
            is_onboarded=False,
            embedding=None,
            connection_count=0,
            project_count=0,
            skills=[],
            experiences=[],
            showcases=[],
            ownedProjects=[],
            memberships=[],
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockProject:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            owner_id=TEST_USER_ID,
            title="Test Project",
            description="A test project description that is long enough",
            required_skills=["Python", "FastAPI"],
            status="open",
            interest="Tech Enthusiast",
            category=None,
            deadline=None,
            total_slots=5,
            embedding=None,
            owner=MockUser(),
            members=[],
            tasks=[],
            applications=[],
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockTask:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            project_id=1,
            title="Test Task",
            status="todo",
            assignee=None,
            assignee_id=None,
            deadline=None,
            assignees=[],
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockShowcase:
    def __init__(self, **kwargs):
        defaults = dict(
            id="showcase-uuid-1",
            author_id=TEST_USER_ID,
            content="Test showcase content that is long enough",
            media_urls=[],
            tags=["test"],
            linked_project_id=None,
            embedding=None,
            author=MockUser(),
            project=None,
            likes=[],
            comments=[],
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockApplication:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            project_id=1,
            applicant_id="other-user-id",
            status="pending",
            applied_at=NOW,
            project=MockProject(),
            applicant=MockUser(full_name="Other User"),
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockNotification:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            user_id=TEST_USER_ID,
            type="like",
            title="New Like",
            content="Someone liked your post",
            is_read=False,
            link="/showcase/1",
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockConnection:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            sender_id="other-user-id",
            receiver_id=TEST_USER_ID,
            status="pending",
            sender=MockUser(full_name="Other User"),
            receiver=MockUser(),
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockExperience:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            user_id=TEST_USER_ID,
            title="Software Engineer",
            company="Tech Corp",
            description="Worked on cool stuff",
            start_date=datetime(2023, 1, 1, tzinfo=timezone.utc),
            end_date=None,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockWorkspaceMessage:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            project_id=1,
            content="Test message",
            type="text",
            sender_id=TEST_USER_ID,
            sender=MockUser(),
            attachment_url=None,
            attachment_name=None,
            attachment_size=None,
            reply_to_id=None,
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockProjectFile:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            project_id=1,
            user_id=TEST_USER_ID,
            name="test_file.pdf",
            url="https://example.com/file.pdf",
            size=1024,
            mime_type="application/pdf",
            uploader=MockUser(),
            created_at=NOW,
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockTaskAssignee:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            task_id=1,
            user_id=TEST_USER_ID,
            user=MockUser(),
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockProjectMember:
    def __init__(self, **kwargs):
        defaults = dict(
            id=1,
            project_id=1,
            user_id=TEST_USER_ID,
            role="Ketua",
            user=MockUser(),
        )
        defaults.update(kwargs)
        for k, v in defaults.items():
            setattr(self, k, v)


class MockPrisma:
    def __init__(self):
        for model in [
            "user", "skill", "userskill", "project", "task",
            "showcase", "showcaselike", "showcasecomment",
            "projectapplication", "projectmember", "projectfile", "taskassignee", "message",
            "notification", "connection", "experience",
            "otpcode",
        ]:
            setattr(self, model, _make_async_model())

    async def connect(self):
        pass

    async def disconnect(self):
        pass


class _AsyncModelMock:
    def __init__(self):
        self._methods = {}
        for method in [
            "find_unique", "find_first", "find_many", "create",
            "update", "delete", "upsert", "count", "delete_many",
            "update_many", "aggregate", "create_many"
        ]:
            self._methods[method] = AsyncMock()

    def __getattr__(self, name):
        if name in self._methods:
            return self._methods[name]
        return MagicMock()

    def __setattr__(self, name, value):
        if name in ("_methods",):
            super().__setattr__(name, value)
        else:
            self._methods[name] = value


def _make_async_model():
    return _AsyncModelMock()


@pytest.fixture
def mock_db():
    return MockPrisma()


@pytest.fixture(autouse=True)
def mock_cloudinary():
    with patch("app.services.storage.cloudinary") as mock:
        mock.uploader.upload.return_value = {
            "secure_url": "https://res.cloudinary.com/test/image.jpg"
        }
        yield mock


@pytest.fixture(autouse=True)
def mock_mistral():
    with patch("app.services.ai_nlp.mistral_client") as mock:
        mock.files.upload.return_value = MagicMock(id="file-id-123")
        mock.files.get_signed_url.return_value = MagicMock(
            url="https://mistral.ai/signed/doc.pdf"
        )
        mock_page = MagicMock()
        mock_page.markdown = "Extracted OCR text"
        mock.ocr.process.return_value = MagicMock(pages=[mock_page])
        yield mock


@pytest.fixture(autouse=True)
def mock_groq():
    with patch("app.services.ai_nlp.client") as mock:
        mock_response = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = json.dumps({
            "nama": "Test User",
            "skills": ["Python", "FastAPI"],
            "bio_suggestion": "A test bio"
        })
        mock_response.choices = [mock_choice]
        mock.chat.completions.create.return_value = mock_response
        yield mock


@pytest.fixture(autouse=True)
def mock_jwt():
    with patch("jwt.decode") as mock:
        mock.return_value = {
            "uid": TEST_USER_ID,
            "email": TEST_USER_EMAIL,
            "exp": NOW.timestamp() + 86400
        }
        yield mock


@pytest.fixture(autouse=True)
def mock_embeddings():
    with patch("app.services.showcase_service.reembed_showcase"), \
         patch("app.services.project_service.reembed_project"), \
         patch("app.services.project_service.reembed_user"), \
         patch("app.services.profile_service.reembed_user"), \
         patch("app.services.competitions_service.generate", return_value=[0.1] * 384):
        yield


@pytest.fixture(autouse=True)
def mock_mongodb():
    mock_collection = MagicMock()
    mock_cursor = AsyncMock()
    mock_cursor.to_list = AsyncMock(return_value=[])
    mock_collection.find.return_value.limit.return_value = mock_cursor
    mock_collection.count_documents = AsyncMock(return_value=0)
    mock_collection.delete_one = AsyncMock(return_value=MagicMock(deleted_count=1))
    with patch("app.services.fyp_service.get_competition_collection", return_value=mock_collection), \
         patch("app.services.competitions_service.get_competition_collection", return_value=mock_collection), \
         patch("app.services.admin_service.get_competition_collection", return_value=mock_collection):
        yield mock_collection


@pytest.fixture
def app(mock_db):
    from app.main import app as fastapi_app
    from app.core.database import get_db
    from app.core.security import verify_admin_token

    fastapi_app.dependency_overrides[get_db] = lambda: mock_db
    fastapi_app.dependency_overrides[verify_admin_token] = lambda: {"admin_id": "admin-id", "role": "admin"}

    yield fastapi_app

    fastapi_app.dependency_overrides.clear()


@pytest.fixture
async def client(app) -> AsyncGenerator[AsyncClient, None]:
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac


@pytest.fixture
def auth_header():
    return {"Authorization": "Bearer test-jwt-token"}
