import pytest
from unittest.mock import MagicMock
from datetime import datetime, UTC

# ==========================================
# TEST: POST /onboarding/extract-cv
# ==========================================
def test_extract_cv_success(client, mocker):
    """Test mengekstrak data CV menggunakan mock layanan AI."""
    pdf_content = b"%PDF-1.4 mock content"

    mocker.patch("app.api.onboarding.extract_photo_from_pdf", return_value=b"mock_photo_bytes")
    mocker.patch("app.api.onboarding.upload_image_to_cloudinary", return_value="https://mock_url.com/photo.jpg")
    mocker.patch("app.api.onboarding.extract_text_from_pdf", return_value="Mock resume text")
    mocker.patch("app.api.onboarding.process_resume_with_gemini", return_value={
        "nama": "Ahmad Saif",
        "skills": ["Python", "FastAPI"],
        "bio_suggestion": "Seorang backend developer"
    })

    response = client.post(
        "/onboarding/extract-cv",
        files={"file": ("resume.pdf", pdf_content, "application/pdf")}
    )

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["nama"] == "Ahmad Saif"
    assert "Python" in data["data"]["skills_terdeteksi"]

def test_extract_cv_invalid_format(client):
    """Test upload file selain PDF akan gagal."""
    response = client.post(
        "/onboarding/extract-cv",
        files={"file": ("resume.txt", b"Bukan PDF", "text/plain")}
    )
    assert response.status_code == 400


# ==========================================
# TEST: PUT /onboarding/save-profile
# ==========================================
def test_save_user_profile(client, mock_db):
    """Test update profil user yang sudah terdaftar."""
    # Mock user sudah ada
    mock_existing = MagicMock()
    mock_db.user.find_unique.return_value = mock_existing

    # Mock return value db.user.update
    mock_user = MagicMock()
    mock_user.id = "test_uid_123"
    mock_user.nim = "20210001"
    mock_user.full_name = "Ahmad Saif"
    mock_user.bio = "Backend Dev"
    mock_user.photo_url = "http://mock.com/img"
    mock_db.user.update.return_value = mock_user

    # Mock skill
    mock_skill = MagicMock()
    mock_skill.id = 1
    mock_db.skill.upsert.return_value = mock_skill

    payload = {
        "full_name": "Ahmad Saif",
        "bio": "Backend Dev",
        "photo_url": "http://mock.com/img",
        "skills": ["Python", "FastAPI"]
    }

    response = client.put("/onboarding/save-profile", json=payload)

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["full_name"] == "Ahmad Saif"
    assert mock_db.user.update.called

def test_save_profile_user_not_registered(client, mock_db):
    """Test gagal update profil jika user belum register."""
    mock_db.user.find_unique.return_value = None

    payload = {
        "full_name": "Ahmad Saif",
        "bio": "Backend Dev",
        "skills": []
    }
    response = client.put("/onboarding/save-profile", json=payload)
    assert response.status_code == 404


# ==========================================
# TEST: GET /onboarding/profile
# ==========================================
def test_get_my_profile_success(client, mock_db):
    """Test mengambil data profil user."""
    mock_user = MagicMock()
    mock_user.id = "test_uid_123"
    mock_user.nim = "20210001"
    mock_user.full_name = "Ahmad Saif"
    mock_user.bio = "Backend Dev"
    mock_user.photo_url = "http://mock.com/img"
    mock_user.email = "test@example.com"
    mock_user.social_links = None
    mock_user.googleId = None
    mock_user.created_at = datetime.now(UTC)

    mock_us1 = MagicMock()
    mock_us1.skill.name = "Python"
    mock_user.skills = [mock_us1]

    mock_db.user.find_unique.return_value = mock_user

    response = client.get("/onboarding/profile")

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "success"
    assert data["data"]["full_name"] == "Ahmad Saif"
    assert "Python" in data["data"]["skills"]

def test_get_my_profile_not_found(client, mock_db):
    """Test respon jika user belum terdaftar."""
    mock_db.user.find_unique.return_value = None
    response = client.get("/onboarding/profile")
    assert response.status_code == 404
