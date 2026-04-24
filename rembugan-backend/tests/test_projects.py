import pytest
from unittest.mock import MagicMock
from datetime import datetime, UTC

# ==========================================
# TEST: POST /projects/create
# ==========================================
def test_create_project_success(client, mock_db):
    # Mock user terdaftar
    mock_user = MagicMock()
    mock_db.user.find_unique.return_value = mock_user

    # Mock return create project
    mock_project = MagicMock()
    mock_project.id = 1
    mock_project.title = "Aplikasi AI"
    mock_project.description = "Proyek AI panjang sekali deskripsinya."
    mock_project.required_skills = ["Python"]
    mock_project.status = "open"
    mock_project.owner.full_name = "Ahmad"
    mock_project.created_at = datetime.now(UTC)
    mock_db.project.create.return_value = mock_project

    payload = {
        "title": "Aplikasi AI",
        "description": "Proyek AI panjang sekali deskripsinya.",
        "required_skills": ["Python"]
    }

    response = client.post("/projects/create", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["title"] == "Aplikasi AI"
    assert mock_db.project.create.called

def test_create_project_user_not_found(client, mock_db):
    mock_db.user.find_unique.return_value = None

    payload = {
        "title": "Aplikasi AI",
        "description": "Proyek AI panjang sekali deskripsinya.",
        "required_skills": ["Python"]
    }
    response = client.post("/projects/create", json=payload)
    
    assert response.status_code == 404
    assert response.json()["detail"] == "User belum terdaftar. Harap selesaikan onboarding."


# ==========================================
# TEST: GET /projects/explore
# ==========================================
def test_explore_projects(client, mock_db):
    # Mock return list project
    mock_project = MagicMock()
    mock_project.id = 1
    mock_project.title = "Aplikasi AI"
    mock_project.description = "Desc"
    mock_project.required_skills = ["Python"]
    mock_project.status = "open"
    mock_project.owner.full_name = "Ahmad"
    mock_project.members = [MagicMock()] # 1 member
    mock_project.created_at = datetime.now(UTC)
    
    mock_db.project.find_many.return_value = [mock_project]

    response = client.get("/projects/explore")
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 1
    assert data["data"][0]["member_count"] == 1


# ==========================================
# TEST: GET /projects/{project_id}
# ==========================================
def test_get_project_detail(client, mock_db):
    mock_project = MagicMock()
    mock_project.id = 1
    mock_project.title = "Aplikasi AI"
    mock_project.description = "Desc"
    mock_project.required_skills = ["Python"]
    mock_project.status = "open"
    mock_project.owner.full_name = "Ahmad"
    mock_project.created_at = datetime.now(UTC)
    
    # Mock members relation
    mock_member = MagicMock()
    mock_member.id = 1
    mock_member.user_id = "user_1"
    mock_member.user.full_name = "Ahmad"
    mock_member.role = "Ketua"
    mock_project.members = [mock_member]
    
    # Empty tasks & applications
    mock_project.tasks = []
    mock_project.applications = []

    mock_db.project.find_unique.return_value = mock_project

    response = client.get("/projects/1")
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]["members"]) == 1
    assert data["data"]["members"][0]["role"] == "Ketua"

def test_get_project_detail_not_found(client, mock_db):
    mock_db.project.find_unique.return_value = None
    response = client.get("/projects/999")
    assert response.status_code == 404
