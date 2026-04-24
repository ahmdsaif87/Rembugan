import pytest
from unittest.mock import MagicMock
from datetime import datetime, UTC

# ==========================================
# TEST: POST /workspace/{project_id}/tasks
# ==========================================
def test_create_task_success(client, mock_db):
    # Mock project exists
    mock_db.project.find_unique.return_value = MagicMock()
    
    # Mock user is a member
    mock_db.projectmember.find_first.return_value = MagicMock()
    
    # Mock task created
    mock_task = MagicMock()
    mock_task.id = 1
    mock_task.title = "Bikin API"
    mock_task.status = "todo"
    mock_task.assignee.full_name = "Ahmad"
    mock_task.created_at = datetime.now(UTC)
    mock_db.task.create.return_value = mock_task

    payload = {"title": "Bikin API", "assignee_id": "test_uid_123"}
    response = client.post("/workspace/1/tasks", json=payload)
    
    assert response.status_code == 200
    assert response.json()["status"] == "success"
    assert mock_db.task.create.called

def test_create_task_not_member(client, mock_db):
    mock_db.project.find_unique.return_value = MagicMock()
    # User is not a member
    mock_db.projectmember.find_first.return_value = None

    payload = {"title": "Bikin API", "assignee_id": "test_uid_123"}
    response = client.post("/workspace/1/tasks", json=payload)
    
    assert response.status_code == 403
    assert "bukan member" in response.json()["detail"]


# ==========================================
# TEST: PUT /workspace/tasks/{task_id}/move
# ==========================================
def test_move_task(client, mock_db):
    # Mock task exists
    mock_db.task.find_unique.return_value = MagicMock()
    
    # Mock task updated
    mock_updated = MagicMock()
    mock_updated.id = 1
    mock_updated.title = "API"
    mock_updated.status = "doing"
    mock_db.task.update.return_value = mock_updated

    response = client.put("/workspace/tasks/1/move", json={"status": "doing"})
    
    assert response.status_code == 200
    assert response.json()["data"]["status"] == "doing"
