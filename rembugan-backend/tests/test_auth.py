import pytest
from unittest.mock import MagicMock
from app.core.security import hash_password


# ==========================================
# TEST: POST /auth/register
# ==========================================
def test_register_success(client, mock_db):
    """Test registrasi user baru berhasil."""
    mock_db.user.find_unique.return_value = None  # NIM belum terdaftar

    mock_user = MagicMock()
    mock_user.id = "new_user_id"
    mock_user.nim = "230401099"
    mock_user.full_name = "Test User"
    mock_user.email = None
    mock_db.user.create.return_value = mock_user

    payload = {
        "nim": "230401099",
        "password": "password123",
        "full_name": "Test User"
    }
    response = client.post("/auth/register", json=payload)

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["access_token"]
    assert data["data"]["full_name"] == "Test User"

def test_register_duplicate_nim(client, mock_db):
    """Test gagal registrasi jika NIM sudah terdaftar."""
    mock_db.user.find_unique.return_value = MagicMock()  # NIM sudah ada

    payload = {
        "nim": "230401010",
        "password": "password123",
        "full_name": "Duplicate"
    }
    response = client.post("/auth/register", json=payload)

    assert response.status_code == 400
    assert "sudah terdaftar" in response.json()["detail"]


# ==========================================
# TEST: POST /auth/login
# ==========================================
def test_login_success(client, mock_db):
    """Test login dengan NIM dan password yang benar."""
    mock_user = MagicMock()
    mock_user.id = "user_id_123"
    mock_user.nim = "230401010"
    mock_user.password = hash_password("password123")
    mock_user.full_name = "Rudi Sutrisno"
    mock_user.email = None
    mock_db.user.find_unique.return_value = mock_user

    payload = {"nim": "230401010", "password": "password123"}
    response = client.post("/auth/login", json=payload)

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["access_token"]

def test_login_wrong_password(client, mock_db):
    """Test login gagal karena password salah."""
    mock_user = MagicMock()
    mock_user.password = hash_password("password123")
    mock_db.user.find_unique.return_value = mock_user

    payload = {"nim": "230401010", "password": "salah_banget"}
    response = client.post("/auth/login", json=payload)

    assert response.status_code == 401

def test_login_nim_not_found(client, mock_db):
    """Test login gagal karena NIM tidak terdaftar."""
    mock_db.user.find_unique.return_value = None

    payload = {"nim": "999999999", "password": "password123"}
    response = client.post("/auth/login", json=payload)

    assert response.status_code == 401
