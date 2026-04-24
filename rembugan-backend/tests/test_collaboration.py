import pytest
from unittest.mock import MagicMock
from datetime import datetime, UTC

# ==========================================
# TEST: POST /collaboration/apply
# ==========================================
def test_apply_project_success(client, mock_db):
    # Mock project
    mock_project = MagicMock()
    mock_project.id = 1
    mock_project.status = "open"
    mock_project.owner_id = "other_user_id"
    mock_db.project.find_unique.return_value = mock_project
    
    # Mock belum melamar
    mock_db.projectapplication.find_first.return_value = None
    
    # Mock hasil lamaran
    mock_app = MagicMock()
    mock_app.id = 10
    mock_app.project.title = "Proyek AI"
    mock_app.applicant.full_name = "Ahmad"
    mock_app.status = "pending"
    mock_app.applied_at = datetime.now(UTC)
    mock_db.projectapplication.create.return_value = mock_app

    response = client.post("/collaboration/apply", json={"project_id": 1})
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["id"] == 10

def test_apply_own_project_error(client, mock_db):
    mock_project = MagicMock()
    mock_project.status = "open"
    mock_project.owner_id = "test_uid_123" # Sama dengan mock token
    mock_db.project.find_unique.return_value = mock_project

    response = client.post("/collaboration/apply", json={"project_id": 1})
    assert response.status_code == 400
    assert "sendiri" in response.json()["detail"]


# ==========================================
# TEST: PUT /collaboration/applications/{id}/respond
# ==========================================
def test_respond_application_accept(client, mock_db):
    # Mock aplikasi pending
    mock_app = MagicMock()
    mock_app.id = 1
    mock_app.project_id = 10
    mock_app.applicant_id = "pelamar_id"
    mock_app.project.owner_id = "test_uid_123" # User login adalah owner
    mock_app.status = "pending"
    mock_db.projectapplication.find_unique.return_value = mock_app
    
    # Mock hasil update
    mock_updated = MagicMock()
    mock_updated.id = 1
    mock_updated.status = "accepted"
    mock_db.projectapplication.update.return_value = mock_updated

    payload = {"status": "accepted", "role": "Anggota"}
    response = client.put("/collaboration/applications/1/respond", json=payload)
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert mock_db.projectapplication.update.called
    assert mock_db.projectmember.create.called # Member dibuat
