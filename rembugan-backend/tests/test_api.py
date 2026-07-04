import pytest
from unittest.mock import AsyncMock, MagicMock, ANY, patch
from datetime import datetime, timezone
from httpx import ASGITransport, AsyncClient


NOW = datetime.now(timezone.utc)

async def _auth_get(client, path, auth_header, **kw):
    return await client.get(path, headers=auth_header, **kw)

async def _auth_post(client, path, auth_header, json=None):
    return await client.post(path, headers=auth_header, json=json or {})

async def _auth_put(client, path, auth_header, json=None):
    return await client.put(path, headers=auth_header, json=json or {})

async def _auth_patch(client, path, auth_header, json=None):
    return await client.patch(path, headers=auth_header, json=json or {})

async def _auth_delete(client, path, auth_header):
    return await client.delete(path, headers=auth_header)


class TestRoot:
    async def test_health_check(self, client):
        resp = await client.get("/")
        assert resp.status_code == 200
        data = resp.json()
        assert data["message"] == "REMBUGAN API Aktif!"
        assert data["version"] == "1.0.0"


class TestAuth:
    async def test_register_success(self, client, mock_db):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(return_value=None)
        mock_db.user.create = AsyncMock(
            return_value=MagicMock(
                id="new-user-id", email="new@example.com", full_name="New User",
                nim="1234567890", major="Informatika",
                handle=None, interest="Tech Enthusiast",
                is_onboarded=False, password="hashed"
            )
        )
        resp = await client.post("/auth/register", json={
            "nim": "1234567890", "password": "rahasia123",
            "full_name": "New User", "major": "Informatika"
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "success"

    async def test_register_duplicate_email(self, client, mock_db):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        resp = await client.post("/auth/register", json={
            "nim": "1234567890", "password": "rahasia123",
            "full_name": "Dup", "major": "Informatika"
        })
        assert resp.status_code == 400
        assert "sudah terdaftar" in resp.json()["detail"]

    async def test_register_invalid_data(self, client):
        resp = await client.post("/auth/register", json={
            "nim": "", "password": "123", "full_name": "A", "major": ""
        })
        assert resp.status_code == 422

    async def test_login_success(self, client, mock_db):
        from unittest.mock import patch
        from tests.conftest import MockUser
        user = MockUser(email_verified=True)
        mock_db.user.find_unique = AsyncMock(return_value=user)
        with patch("app.services.auth_service.verify_password", return_value=True):
            resp = await client.post("/auth/login", json={
                "identifier": "test@example.com", "password": "rahasia123"
            })
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "success"

    async def test_login_wrong_email(self, client, mock_db):
        mock_db.user.find_unique = AsyncMock(return_value=None)
        resp = await client.post("/auth/login", json={
            "identifier": "none@example.com", "password": "test"
        })
        assert resp.status_code == 401

    async def test_login_wrong_password(self, client, mock_db):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(return_value=MockUser(email_verified=True))
        with patch("app.services.auth_service.verify_password", return_value=False):
            resp = await client.post("/auth/login", json={
                "identifier": "test@example.com", "password": "wrong"
            })
        assert resp.status_code == 401

    async def test_me_success(self, client, mock_db, auth_header):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(return_value=MockUser(is_onboarded=True))
        resp = await _auth_get(client, "/auth/me", auth_header)
        assert resp.status_code == 200
        assert resp.json()["data"]["full_name"] == "Test User"

    async def test_me_not_found(self, client, mock_db, auth_header):
        mock_db.user.find_unique = AsyncMock(return_value=None)
        resp = await _auth_get(client, "/auth/me", auth_header)
        assert resp.status_code == 404


class TestOnboarding:
    async def test_extract_cv_success(self, client, auth_header):
        resp = await client.post(
            "/onboarding/extract-cv",
            files={"file": ("cv.pdf", b"%PDF-fake-content", "application/pdf")},
            headers=auth_header,
        )
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "success"
        assert data["data"]["nama"] == "Test User"

    async def test_extract_cv_not_pdf(self, client, auth_header):
        resp = await client.post(
            "/onboarding/extract-cv",
            files={"file": ("cv.txt", b"not a pdf", "text/plain")},
            headers=auth_header,
        )
        assert resp.status_code == 400
        assert "PDF" in resp.json()["detail"]

    async def test_save_profile_success(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockSkill
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        mock_db.user.update = AsyncMock(return_value=MockUser(is_onboarded=True))
        mock_db.userskill.delete_many = AsyncMock()
        existing_skills_data = [MockSkill(id=1, name="Python"), MockSkill(id=2, name="FastAPI")]
        mock_db.skill.find_many = AsyncMock(return_value=existing_skills_data)
        mock_db.skill.create_many = AsyncMock()
        mock_db.userskill.create_many = AsyncMock()
        resp = await _auth_put(client, "/onboarding/save-profile", auth_header, json={
            "full_name": "Test User",
            "bio": "A bio",
            "photo_url": "https://example.com/photo.jpg",
            "skills": ["Python", "FastAPI"]
        })
        assert resp.status_code == 200
        assert resp.json()["status"] == "success"

    async def test_save_profile_user_not_found(self, client, mock_db, auth_header):
        mock_db.user.find_unique = AsyncMock(return_value=None)
        resp = await _auth_put(client, "/onboarding/save-profile", auth_header, json={
            "full_name": "Test", "skills": []
        })
        assert resp.status_code == 404

    async def test_get_profile_success(self, client, mock_db, auth_header):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(return_value=MockUser(is_onboarded=True))
        resp = await _auth_get(client, "/onboarding/profile", auth_header)
        assert resp.status_code == 200
        assert resp.json()["data"]["full_name"] == "Test User"


class TestProjects:
    async def test_create_project_success(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockProject
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        mock_db.project.create = AsyncMock(return_value=MockProject())
        resp = await _auth_post(client, "/projects/create", auth_header, json={
            "title": "My New Project",
            "description": "This is a description with enough characters to pass validation",
            "required_skills": ["Python", "FastAPI"]
        })
        assert resp.status_code == 200
        assert resp.json()["status"] == "success"

    async def test_create_project_user_not_found(self, client, mock_db, auth_header):
        mock_db.user.find_unique = AsyncMock(return_value=None)
        resp = await _auth_post(client, "/projects/create", auth_header, json={
            "title": "Project", "description": "x" * 25, "required_skills": ["A"]
        })
        assert resp.status_code == 404

    async def test_explore_projects(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockProject
        mock_db.user.find_unique = AsyncMock(
            return_value=MockUser(skills=[MagicMock(skill=MagicMock(name="Python"))])
        )
        mock_db.project.find_many = AsyncMock(return_value=[MockProject()])
        mock_db.project.count = AsyncMock(return_value=1)
        resp = await _auth_get(client, "/projects/explore", auth_header,
                               params={"page": 1, "limit": 10})
        assert resp.status_code == 200
        assert resp.json()["status"] == "success"

    async def test_my_projects(self, client, mock_db, auth_header):
        from tests.conftest import MockProject
        mock_db.project.find_many = AsyncMock(return_value=[MockProject()])
        resp = await _auth_get(client, "/projects/my-projects", auth_header)
        assert resp.status_code == 200

    async def test_project_detail(self, client, mock_db, auth_header):
        from tests.conftest import MockProject
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        resp = await _auth_get(client, "/projects/1", auth_header)
        assert resp.status_code == 200
        assert resp.json()["data"]["title"] == "Test Project"

    async def test_project_detail_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=None)
        resp = await _auth_get(client, "/projects/999", auth_header)
        assert resp.status_code == 404

    async def test_archive_project(self, client, mock_db, auth_header):
        from tests.conftest import MockProject
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(owner_id="test-user-uuid-1234", status="open")
        )
        mock_db.project.update = AsyncMock(
            return_value=MockProject(status="completed")
        )
        resp = await _auth_post(client, "/projects/1/archive", auth_header)
        assert resp.status_code == 200
        assert resp.json()["data"]["status"] == "completed"

    async def test_archive_project_not_owner(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(owner_id="other-user", status="open")
        )
        resp = await _auth_post(client, "/projects/1/archive", auth_header)
        assert resp.status_code == 403


class TestCollaboration:
    async def test_apply_to_project(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="other-user", status="open")
        )
        mock_db.projectapplication.find_first = AsyncMock(return_value=None)
        mock_db.projectapplication.create = AsyncMock(
            return_value=MagicMock(
                id=1, status="pending",
                project=MagicMock(title="Test"),
                applicant=MagicMock(full_name="Test"),
                applied_at=NOW
            )
        )
        from tests.conftest import MockNotification
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_post(client, "/collaboration/1/apply", auth_header,
                                json={"message": "Saya tertarik!"})
        assert resp.status_code == 200

    async def test_apply_own_project(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="test-user-uuid-1234")
        )
        resp = await _auth_post(client, "/collaboration/1/apply", auth_header,
                                json={"message": "Saya tertarik!"})
        assert resp.status_code == 400

    async def test_apply_duplicate(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="other-user", status="open")
        )
        mock_db.projectapplication.find_first = AsyncMock(
            return_value=MagicMock(status="pending")
        )
        resp = await _auth_post(client, "/collaboration/1/apply", auth_header,
                                json={"message": "Saya tertarik!"})
        assert resp.status_code == 400

    async def test_list_applications(self, client, mock_db, auth_header):
        from tests.conftest import MockApplication
        mock_db.projectapplication.find_many = AsyncMock(return_value=[MockApplication()])
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(owner_id="test-user-uuid-1234")
        )
        resp = await _auth_get(client, "/collaboration/applications/1", auth_header)
        assert resp.status_code == 200

    async def test_respond_accept(self, client, mock_db, auth_header):
        mock_db.projectapplication.find_unique = AsyncMock(
            return_value=MagicMock(
                id=1, status="pending",
                project=MagicMock(owner_id="test-user-uuid-1234", title="Test", total_slots=None),
                applicant_id="other-user"
            )
        )
        mock_db.projectapplication.update = AsyncMock(
            return_value=MagicMock(id=1, status="accepted")
        )
        mock_db.projectmember.create = AsyncMock()
        mock_db.projectmember.count = AsyncMock(return_value=0)
        mock_db.project.find_unique = AsyncMock(return_value=MagicMock(total_slots=None))
        mock_db.project.update = AsyncMock()
        from tests.conftest import MockNotification
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_put(client, "/collaboration/applications/1/respond",
                               auth_header, json={"status": "accepted"})
        assert resp.status_code == 200

    async def test_respond_reject(self, client, mock_db, auth_header):
        mock_db.projectapplication.find_unique = AsyncMock(
            return_value=MagicMock(
                id=1, status="pending",
                project=MagicMock(owner_id="test-user-uuid-1234", title="Test"),
                applicant_id="other-user"
            )
        )
        mock_db.projectapplication.update = AsyncMock(
            return_value=MagicMock(id=1, status="rejected")
        )
        from tests.conftest import MockNotification
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_put(client, "/collaboration/applications/1/respond",
                               auth_header, json={"status": "rejected"})
        assert resp.status_code == 200
        data = resp.json()
        assert data["data"]["new_status"] == "rejected"

    async def test_respond_not_owner(self, client, mock_db, auth_header):
        mock_db.projectapplication.find_unique = AsyncMock(
            return_value=MagicMock(
                project=MagicMock(owner_id="other-owner")
            )
        )
        resp = await _auth_put(client, "/collaboration/applications/1/respond",
                               auth_header, json={"status": "accepted"})
        assert resp.status_code == 403


class TestShowcase:
    async def test_create_showcase(self, client, mock_db, auth_header):
        from tests.conftest import MockShowcase
        mock_db.showcase.create = AsyncMock(return_value=MockShowcase())
        resp = await _auth_post(client, "/showcase/create", auth_header, json={
            "isi_postingan": "This is a showcase post with enough characters"
        })
        assert resp.status_code == 200

    async def test_feed(self, client, mock_db, auth_header):
        from tests.conftest import MockShowcase
        mock_db.showcase.find_many = AsyncMock(return_value=[MockShowcase()])
        mock_db.showcase.count = AsyncMock(return_value=1)
        mock_db.showcase.find_unique = AsyncMock(return_value=MockShowcase())
        resp = await _auth_get(client, "/showcase/feed", auth_header,
                               params={"page": 1, "limit": 10})
        assert resp.status_code == 200

    async def test_like_showcase(self, client, mock_db, auth_header):
        from tests.conftest import MockShowcase, MockNotification
        mock_db.showcase.find_unique = AsyncMock(return_value=MockShowcase())
        mock_db.showcaselike.find_first = AsyncMock(return_value=None)
        mock_db.showcaselike.create = AsyncMock(return_value=MagicMock())
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_post(client, "/showcase/showcase-uuid-1/like", auth_header)
        assert resp.status_code == 200

    async def test_unlike_showcase(self, client, mock_db, auth_header):
        from tests.conftest import MockShowcase
        mock_db.showcase.find_unique = AsyncMock(return_value=MockShowcase())
        mock_db.showcaselike.find_first = AsyncMock(return_value=MagicMock(id=1))
        mock_db.showcaselike.delete = AsyncMock()
        resp = await _auth_delete(client, "/showcase/showcase-uuid-1/like", auth_header)
        assert resp.status_code == 200

    async def test_comment_showcase(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockShowcase, MockNotification
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        mock_db.showcase.find_unique = AsyncMock(return_value=MockShowcase())
        mock_db.showcasecomment.create = AsyncMock(
            return_value=MagicMock(id=1, showcase_id="showcase-uuid-1")
        )
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_post(client, "/showcase/showcase-uuid-1/comment",
                                auth_header, json={"content": "Nice post!"})
        assert resp.status_code == 200

    async def test_comment_reply(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockShowcase, MockNotification
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        mock_db.showcase.find_unique = AsyncMock(return_value=MockShowcase())
        mock_db.showcasecomment.create = AsyncMock(
            return_value=MagicMock(id=2, showcase_id="showcase-uuid-1")
        )
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_post(client, "/showcase/showcase-uuid-1/comment",
                                auth_header, json={"content": "Reply!", "parent_id": 1})
        assert resp.status_code == 200


class TestFYP:
    async def test_fyp(self, client, mock_db, mock_mongodb, auth_header):
        mock_db.user.find_unique = AsyncMock(
            return_value=MagicMock(
                id="test-user-uuid-1234",
                interest="Tech Enthusiast",
                skills=[MagicMock(skill=MagicMock(name="Python"))]
            )
        )
        mock_db.showcase.find_many = AsyncMock(return_value=[])
        mock_db.project.find_many = AsyncMock(return_value=[])
        mock_mongodb.find.return_value.to_list = AsyncMock(return_value=[])
        resp = await _auth_get(client, "/fyp/", auth_header)
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert "showcases" in data
        assert "projects" in data
        assert "competitions" in data


class TestProfile:
    async def test_my_profile(self, client, mock_db, auth_header):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(
            return_value=MockUser(skills=[MagicMock(skill=MagicMock(name="Python"))])
        )
        mock_db.connection.count = AsyncMock(return_value=5)
        resp = await _auth_get(client, "/profile/me", auth_header)
        assert resp.status_code == 200

    async def test_other_profile(self, client, mock_db):
        from tests.conftest import MockUser
        mock_db.user.find_unique = AsyncMock(
            return_value=MockUser(skills=[MagicMock(skill=MagicMock(name="Python"))])
        )
        mock_db.connection.count = AsyncMock(return_value=5)
        resp = await client.get("/profile/other-user-id")
        assert resp.status_code == 200

    async def test_profile_not_found(self, client, mock_db):
        mock_db.user.find_unique = AsyncMock(return_value=None)
        resp = await client.get("/profile/nonexistent")
        assert resp.status_code == 404

    async def test_update_settings(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, TEST_USER_FULL_NAME
        mock_db.user.find_first = AsyncMock(return_value=None)
        mock_db.user.update = AsyncMock(return_value=MockUser())
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        resp = await _auth_patch(client, "/profile/settings", auth_header, json={
            "full_name": "Updated Name",
            "interest": "Design Enthusiast"
        })
        assert resp.status_code == 200
        data = resp.json()["data"]
        assert data["full_name"] == TEST_USER_FULL_NAME


class TestNotifications:
    async def test_list_notifications(self, client, mock_db, auth_header):
        from tests.conftest import MockNotification
        mock_db.notification.find_many = AsyncMock(return_value=[MockNotification()])
        mock_db.notification.count = AsyncMock(return_value=1)
        resp = await _auth_get(client, "/notifications/", auth_header)
        assert resp.status_code == 200

    async def test_mark_read(self, client, mock_db, auth_header):
        from tests.conftest import MockNotification
        mock_db.notification.find_unique = AsyncMock(return_value=MockNotification())
        mock_db.notification.update = AsyncMock(return_value=MockNotification(is_read=True))
        resp = await _auth_put(client, "/notifications/1/read", auth_header)
        assert resp.status_code == 200

    async def test_mark_read_not_owner(self, client, mock_db, auth_header):
        mock_db.notification.find_unique = AsyncMock(
            return_value=MagicMock(user_id="other-user")
        )
        resp = await _auth_put(client, "/notifications/1/read", auth_header)
        assert resp.status_code == 403


class TestConnections:
    async def test_my_connections(self, client, mock_db, auth_header):
        from tests.conftest import MockConnection
        mock_db.connection.find_many = AsyncMock(return_value=[MockConnection(status="accepted")])
        resp = await _auth_get(client, "/connections/", auth_header)
        assert resp.status_code == 200

    async def test_send_request(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockNotification
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        mock_db.connection.find_first = AsyncMock(return_value=None)
        mock_db.connection.create = AsyncMock(return_value=MagicMock(id=1))
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_post(client, "/connections/send/other-user-id", auth_header)
        assert resp.status_code == 200

    async def test_accept_connection(self, client, mock_db, auth_header):
        from tests.conftest import MockUser, MockNotification
        mock_db.user.find_unique = AsyncMock(return_value=MockUser())
        mock_db.connection.find_unique = AsyncMock(
            return_value=MagicMock(id=1, receiver_id="test-user-uuid-1234", status="pending")
        )
        mock_db.connection.update = AsyncMock(return_value=MagicMock(status="accepted"))
        mock_db.notification.create = AsyncMock(return_value=MockNotification())
        resp = await _auth_put(client, "/connections/accept/1", auth_header)
        assert resp.status_code == 200

    async def test_reject_connection(self, client, mock_db, auth_header):
        mock_db.connection.find_unique = AsyncMock(
            return_value=MagicMock(id=1, receiver_id="test-user-uuid-1234", status="pending")
        )
        mock_db.connection.update = AsyncMock(return_value=MagicMock(status="rejected"))
        resp = await _auth_put(client, "/connections/reject/1", auth_header)
        assert resp.status_code == 200


class TestAdmin:
    async def test_admin_stats(self, client, mock_db, mock_mongodb):
        for model in ["user", "project", "showcase", "task", "projectapplication"]:
            getattr(mock_db, model).count = AsyncMock(return_value=10)
        mock_mongodb.count_documents = AsyncMock(return_value=5)
        resp = await client.get("/admin/stats")
        assert resp.status_code == 200
        data = resp.json()
        assert data["data"]["total_users"] == 10
        assert data["data"]["total_projects"] == 10
        assert data["data"]["scraped_competitions"] == 5

    async def test_admin_list_users(self, client, mock_db):
        from tests.conftest import MockUser
        mock_db.user.find_many = AsyncMock(return_value=[MockUser()])
        mock_db.user.count = AsyncMock(return_value=1)
        resp = await client.get("/admin/users")
        assert resp.status_code == 200

    async def test_admin_list_projects(self, client, mock_db):
        from tests.conftest import MockProject
        mock_db.project.find_many = AsyncMock(return_value=[MockProject()])
        mock_db.project.count = AsyncMock(return_value=1)
        resp = await client.get("/admin/projects")
        assert resp.status_code == 200

    async def test_admin_list_showcases(self, client, mock_db):
        from tests.conftest import MockShowcase
        mock_db.showcase.find_many = AsyncMock(return_value=[MockShowcase()])
        mock_db.showcase.count = AsyncMock(return_value=1)
        resp = await client.get("/admin/showcases")
        assert resp.status_code == 200

    async def test_admin_list_tasks(self, client, mock_db):
        from tests.conftest import MockTask
        mock_db.task.find_many = AsyncMock(return_value=[MockTask()])
        mock_db.task.count = AsyncMock(return_value=1)
        resp = await client.get("/admin/tasks")
        assert resp.status_code == 200

    async def test_admin_list_applications(self, client, mock_db):
        from tests.conftest import MockApplication
        mock_db.projectapplication.find_many = AsyncMock(return_value=[MockApplication()])
        mock_db.projectapplication.count = AsyncMock(return_value=1)
        resp = await client.get("/admin/applications")
        assert resp.status_code == 200

    async def test_admin_list_competitions(self, client, mock_mongodb):
        mock_mongodb.find.return_value.to_list = AsyncMock(return_value=[])
        resp = await client.get("/admin/competitions")
        assert resp.status_code == 200

    async def test_admin_delete_user(self, client, mock_db):
        mock_db.user.delete = AsyncMock(return_value=MagicMock())
        resp = await client.delete("/admin/users/some-id")
        assert resp.status_code == 200

    async def test_admin_delete_project(self, client, mock_db):
        mock_db.project.delete = AsyncMock(return_value=MagicMock())
        resp = await client.delete("/admin/projects/1")
        assert resp.status_code == 200

    async def test_admin_delete_showcase(self, client, mock_db):
        mock_db.showcase.delete = AsyncMock(return_value=MagicMock())
        resp = await client.delete("/admin/showcases/some-id")
        assert resp.status_code == 200

    async def test_admin_delete_task(self, client, mock_db):
        mock_db.task.delete = AsyncMock(return_value=MagicMock())
        resp = await client.delete("/admin/tasks/1")
        assert resp.status_code == 200

    async def test_admin_delete_application(self, client, mock_db):
        mock_db.projectapplication.delete = AsyncMock(return_value=MagicMock())
        resp = await client.delete("/admin/applications/1")
        assert resp.status_code == 200

    async def test_admin_delete_competition(self, client, mock_mongodb):
        mock_mongodb.delete_one = AsyncMock(return_value=MagicMock(deleted_count=1))
        resp = await client.delete("/admin/competitions/507f1f77bcf86cd799439011")
        assert resp.status_code == 200


class TestWorkspace:
    async def test_list_workspaces(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockTask, MockApplication, MockWorkspaceMessage
        mock_db.project.find_many = AsyncMock(return_value=[MockProject()])
        mock_db.projectmember.find_many = AsyncMock(
            return_value=[MagicMock(project=MockProject(), role="Anggota")]
        )
        mock_db.task.find_many = AsyncMock(return_value=[MockTask()])
        mock_db.projectapplication.find_many = AsyncMock(return_value=[])
        mock_db.message.find_many = AsyncMock(return_value=[MockWorkspaceMessage()])
        resp = await _auth_get(client, "/workspace/", auth_header)
        assert resp.status_code == 200
        data = resp.json()
        assert "data" in data

    async def test_get_workspace_detail(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockProjectMember, MockTask, MockWorkspaceMessage
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        mock_db.projectmember.find_many = AsyncMock(
            return_value=[MockProjectMember()]
        )
        mock_db.task.find_many = AsyncMock(return_value=[MockTask()])
        mock_db.projectapplication.find_many = AsyncMock(return_value=[])
        mock_db.message.find_first = AsyncMock(return_value=MockWorkspaceMessage())
        mock_db.user.find_unique = AsyncMock(
            return_value=MagicMock(full_name="Test User")
        )
        resp = await _auth_get(client, "/workspace/1", auth_header)
        assert resp.status_code == 200
        data = resp.json()
        assert data["data"]["name"] == "Test Project"

    async def test_get_workspace_detail_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=None)
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        resp = await _auth_get(client, "/workspace/999", auth_header)
        assert resp.status_code == 404

    async def test_create_task(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockProjectMember
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        mock_db.task.create = AsyncMock(
            return_value=MagicMock(
                id=1, title="New Task", status="todo",
                deadline=None, created_at=NOW,
                assignees=[],
            )
        )
        mock_db.notification.create = AsyncMock()
        resp = await _auth_post(client, "/workspace/1/tasks", auth_header, json={
            "title": "New Task",
            "assignee_ids": [],
        })
        assert resp.status_code == 200
        data = resp.json()
        assert data["data"]["title"] == "New Task"

    async def test_create_task_not_member(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="other-owner")
        )
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        resp = await _auth_post(client, "/workspace/1/tasks", auth_header, json={
            "title": "New Task",
            "assignee_ids": [],
        })
        assert resp.status_code == 403

    async def test_move_task(self, client, mock_db, auth_header):
        mock_db.task.find_unique = AsyncMock(
            return_value=MagicMock(id=1, project_id=1, title="Test Task", status="todo")
        )
        mock_db.task.update = AsyncMock(
            return_value=MagicMock(id=1, title="Test Task", status="doing")
        )
        resp = await _auth_put(client, "/workspace/tasks/1/move", auth_header, json={
            "status": "doing"
        })
        assert resp.status_code == 200
        assert resp.json()["data"]["status"] == "doing"

    async def test_move_task_not_found(self, client, mock_db, auth_header):
        mock_db.task.find_unique = AsyncMock(return_value=None)
        resp = await _auth_put(client, "/workspace/tasks/1/move", auth_header, json={
            "status": "doing"
        })
        assert resp.status_code == 404

    async def test_get_tasks(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockTask
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.task.find_many = AsyncMock(
            return_value=[MockTask()]
        )
        resp = await _auth_get(client, "/workspace/1/tasks", auth_header)
        assert resp.status_code == 200
        data = resp.json()
        assert "board" in data["data"]

    async def test_get_tasks_project_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=None)
        resp = await _auth_get(client, "/workspace/999/tasks", auth_header)
        assert resp.status_code == 404

    async def test_update_task(self, client, mock_db, auth_header):
        from tests.conftest import MockTask, MockProjectMember, MockTaskAssignee
        mock_db.task.find_unique = AsyncMock(
            return_value=MagicMock(
                id=1, title="Old Title", status="todo",
                project=MagicMock(id=1, owner_id="test-user-uuid-1234"),
                assignees=[MockTaskAssignee()],
            )
        )
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        mock_db.taskassignee.delete_many = AsyncMock()
        mock_db.taskassignee.create = AsyncMock()
        mock_db.task.update = AsyncMock(
            return_value=MagicMock(
                id=1, title="Updated Title", status="todo",
                deadline=None, created_at=NOW,
                assignees=[],
            )
        )
        mock_db.notification.create = AsyncMock()
        resp = await _auth_put(client, "/workspace/tasks/1", auth_header, json={
            "title": "Updated Title"
        })
        assert resp.status_code == 200
        assert resp.json()["data"]["title"] == "Updated Title"

    async def test_update_task_not_found(self, client, mock_db, auth_header):
        mock_db.task.find_unique = AsyncMock(return_value=None)
        resp = await _auth_put(client, "/workspace/tasks/999", auth_header, json={
            "title": "Updated"
        })
        assert resp.status_code == 404

    async def test_delete_task(self, client, mock_db, auth_header):
        from tests.conftest import MockProjectMember
        mock_db.task.find_unique = AsyncMock(
            return_value=MagicMock(
                id=1, title="Test Task",
                project=MagicMock(id=1, owner_id="test-user-uuid-1234"),
            )
        )
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        mock_db.task.delete = AsyncMock()
        resp = await _auth_delete(client, "/workspace/tasks/1", auth_header)
        assert resp.status_code == 200

    async def test_delete_task_not_found(self, client, mock_db, auth_header):
        mock_db.task.find_unique = AsyncMock(return_value=None)
        resp = await _auth_delete(client, "/workspace/tasks/999", auth_header)
        assert resp.status_code == 404

    async def test_delete_task_not_member(self, client, mock_db, auth_header):
        mock_db.task.find_unique = AsyncMock(
            return_value=MagicMock(
                id=1, title="Test Task",
                project=MagicMock(id=1, owner_id="other-owner"),
            )
        )
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        resp = await _auth_delete(client, "/workspace/tasks/1", auth_header)
        assert resp.status_code == 403

    async def test_list_files(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockProjectFile
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        mock_db.projectfile.find_many = AsyncMock(return_value=[MockProjectFile()])
        resp = await _auth_get(client, "/workspace/1/files", auth_header)
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["data"]) == 1

    async def test_list_files_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=None)
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        resp = await _auth_get(client, "/workspace/999/files", auth_header)
        assert resp.status_code == 404

    async def test_delete_file(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockProjectFile
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        mock_db.projectfile.find_first = AsyncMock(return_value=MockProjectFile())
        mock_db.projectfile.delete = AsyncMock()
        resp = await _auth_delete(client, "/workspace/1/files/1", auth_header)
        assert resp.status_code == 200

    async def test_delete_file_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=MagicMock(id=1, owner_id="test-user-uuid-1234"))
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        mock_db.projectfile.find_first = AsyncMock(return_value=None)
        resp = await _auth_delete(client, "/workspace/1/files/999", auth_header)
        assert resp.status_code == 404

    async def test_delete_file_forbidden(self, client, mock_db, auth_header):
        from tests.conftest import MockProjectFile, MockProjectMember
        mock_db.project.find_unique = AsyncMock(return_value=MagicMock(id=1, owner_id="other-owner"))
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember(user_id="test-user-uuid-1234")
        )
        mock_db.projectfile.find_first = AsyncMock(return_value=MockProjectFile(user_id="other-user"))
        resp = await _auth_delete(client, "/workspace/1/files/1", auth_header)
        assert resp.status_code == 403

    async def test_list_applicants(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockApplication
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectapplication.find_many = AsyncMock(
            return_value=[MockApplication()]
        )
        resp = await _auth_get(client, "/workspace/1/applicants", auth_header)
        assert resp.status_code == 200

    async def test_list_applicants_not_owner(self, client, mock_db, auth_header):
        from tests.conftest import MockProjectMember
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="other-owner")
        )
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        resp = await _auth_get(client, "/workspace/1/applicants", auth_header)
        assert resp.status_code == 403

    async def test_kick_member(self, client, mock_db, auth_header):
        from tests.conftest import MockProjectMember
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, title="Test", owner_id="test-user-uuid-1234")
        )
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember(user_id="other-user")
        )
        mock_db.projectmember.delete = AsyncMock()
        resp = await _auth_post(client, "/workspace/1/members/other-user/kick", auth_header)
        assert resp.status_code == 200

    async def test_kick_member_not_owner(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="other-owner")
        )
        resp = await _auth_post(client, "/workspace/1/members/other-user/kick", auth_header)
        assert resp.status_code == 403

    async def test_kick_member_self(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="test-user-uuid-1234")
        )
        resp = await _auth_post(client, "/workspace/1/members/test-user-uuid-1234/kick", auth_header)
        assert resp.status_code == 400

    async def test_kick_member_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="test-user-uuid-1234")
        )
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        resp = await _auth_post(client, "/workspace/1/members/nonexistent/kick", auth_header)
        assert resp.status_code == 404

    async def test_end_collaboration(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, title="Test", owner_id="test-user-uuid-1234")
        )
        mock_db.project.update = AsyncMock(
            return_value=MagicMock(id=1, title="Test", status="completed")
        )
        resp = await _auth_post(client, "/workspace/1/end", auth_header)
        assert resp.status_code == 200

    async def test_end_collaboration_not_owner(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(
            return_value=MagicMock(id=1, owner_id="other-owner")
        )
        resp = await _auth_post(client, "/workspace/1/end", auth_header)
        assert resp.status_code == 403

    async def test_end_collaboration_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=None)
        resp = await _auth_post(client, "/workspace/999/end", auth_header)
        assert resp.status_code == 404

    async def test_get_discussions(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockProjectMember, MockWorkspaceMessage
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        mock_db.message.find_many = AsyncMock(return_value=[MockWorkspaceMessage()])
        resp = await _auth_get(client, "/workspace/1/discussions", auth_header)
        assert resp.status_code == 200

    async def test_get_discussions_not_found(self, client, mock_db, auth_header):
        mock_db.project.find_unique = AsyncMock(return_value=None)
        mock_db.projectmember.find_first = AsyncMock(return_value=None)
        resp = await _auth_get(client, "/workspace/999/discussions", auth_header)
        assert resp.status_code == 404

    async def test_get_activities(self, client, mock_db, auth_header):
        from tests.conftest import MockProject, MockProjectMember, MockTask, MockWorkspaceMessage, MockProjectFile
        mock_db.project.find_unique = AsyncMock(return_value=MockProject())
        mock_db.projectmember.find_first = AsyncMock(
            return_value=MockProjectMember()
        )
        mock_db.message.find_many = AsyncMock(return_value=[MockWorkspaceMessage()])
        mock_db.task.find_many = AsyncMock(return_value=[MockTask()])
        mock_db.projectfile.find_many = AsyncMock(return_value=[MockProjectFile()])
        resp = await _auth_get(client, "/workspace/1/activities", auth_header)
        assert resp.status_code == 200


class TestChat:
    async def test_chat_history(self, client, mock_db, auth_header):
        mock_db.message.find_many = AsyncMock(
            return_value=[
                MagicMock(
                    id=1, content="Hello", sender_id="user-1",
                    sender=MagicMock(full_name="User One"),
                    created_at=NOW
                )
            ]
        )
        mock_db.message.count = AsyncMock(return_value=1)
        resp = await _auth_get(client, "/chat/history/1", auth_header, params={"limit": 50})
        assert resp.status_code == 200
        data = resp.json()
        assert data["status"] == "success"
