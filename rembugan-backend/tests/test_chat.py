import pytest
from unittest.mock import MagicMock
from datetime import datetime, timezone, UTC

# ==========================================
# TEST: GET /chat/history/{room_id}
# ==========================================
def test_get_chat_history_project(client, mock_db):
    # Mock messages (Project Room ID = angka misal "1")
    mock_msg = MagicMock()
    mock_msg.id = 1
    mock_msg.content = "Halo proyek!"
    mock_msg.sender_id = "user_1"
    mock_msg.sender.full_name = "Ahmad"
    mock_msg.created_at = datetime.now(UTC)
    
    mock_db.message.find_many.return_value = [mock_msg]

    response = client.get("/chat/history/1")
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 1
    assert data["data"][0]["content"] == "Halo proyek!"

def test_get_chat_history_dm(client, mock_db):
    # Mock messages (DM Room ID = dm_user1_user2)
    mock_msg = MagicMock()
    mock_msg.id = 2
    mock_msg.content = "Halo PM!"
    mock_msg.sender_id = "user1"
    mock_msg.sender.full_name = "Ahmad"
    mock_msg.created_at = datetime.now(UTC)
    
    mock_db.message.find_many.return_value = [mock_msg]

    response = client.get("/chat/history/dm_user1_user2")
    
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert len(data["data"]) == 1
