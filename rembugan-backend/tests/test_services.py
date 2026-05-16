import pytest
from app.services.matchmaking import calculate_match_score
from app.services.storage import upload_image_to_cloudinary
from app.services.ai_vision import extract_photo_from_pdf
from app.services.ai_nlp import extract_text_from_pdf, process_resume_with_ai, draft_project_with_ai


class TestMatchmaking:
    def test_perfect_match(self):
        score = calculate_match_score(
            ["Python", "FastAPI"], ["Python", "FastAPI"]
        )
        assert score == 100

    def test_partial_match(self):
        score = calculate_match_score(
            ["Python", "Django"], ["Python", "FastAPI"]
        )
        assert score == 50

    def test_no_match(self):
        score = calculate_match_score(
            ["Java", "Spring"], ["Python", "FastAPI"]
        )
        assert score == 0

    def test_no_user_skills(self):
        score = calculate_match_score([], ["Python", "FastAPI"])
        assert score == 0

    def test_no_required_skills(self):
        score = calculate_match_score(["Python"], [])
        assert score == 100

    def test_empty_both(self):
        score = calculate_match_score([], [])
        assert score == 100

    def test_case_insensitive(self):
        score = calculate_match_score(
            ["python", "fastapi"], ["Python", "FastAPI"]
        )
        assert score == 100

    def test_whitespace_trimmed(self):
        score = calculate_match_score(
            ["  Python  ", "FastAPI"], ["Python", "FastAPI"]
        )
        assert score == 100

    def test_extra_user_skills(self):
        score = calculate_match_score(
            ["Python", "FastAPI", "Docker", "AWS"], ["Python", "FastAPI"]
        )
        assert score == 100

    def test_all_match_with_many(self):
        score = calculate_match_score(
            ["A", "B", "C", "D"], ["A", "B", "C", "D", "E"]
        )
        assert score == 80


class TestStorage:
    def test_upload_success(self, mock_cloudinary):
        url = upload_image_to_cloudinary(b"test-image-bytes")
        assert url == "https://res.cloudinary.com/test/image.jpg"

    def test_upload_raises_http_exception(self):
        from unittest.mock import patch
        with patch("app.services.storage.cloudinary.uploader.upload") as mock:
            mock.side_effect = Exception("Upload failed")
            from fastapi import HTTPException
            with pytest.raises(HTTPException):
                upload_image_to_cloudinary(b"test")


class TestAiVision:
    def test_extract_photo_found(self):
        from unittest.mock import patch, MagicMock
        mock_doc = MagicMock()
        mock_page = MagicMock()
        mock_page.get_images.return_value = [(1,)]
        mock_doc.__getitem__.return_value = mock_page
        mock_doc.extract_image.return_value = {"image": b"photo-bytes"}

        with patch("fitz.open", return_value=mock_doc):
            result = extract_photo_from_pdf(b"fake-pdf")
            assert result == b"photo-bytes"

    def test_extract_photo_not_found(self):
        from unittest.mock import patch, MagicMock
        mock_doc = MagicMock()
        mock_page = MagicMock()
        mock_page.get_images.return_value = []
        mock_doc.__getitem__.return_value = mock_page

        with patch("fitz.open", return_value=mock_doc):
            result = extract_photo_from_pdf(b"fake-pdf")
            assert result is None

    def test_extract_photo_error(self):
        from unittest.mock import patch
        with patch("fitz.open", side_effect=Exception("corrupt")):
            from fastapi import HTTPException
            with pytest.raises(HTTPException):
                extract_photo_from_pdf(b"corrupt-pdf")


class TestAiNlp:
    def test_extract_text_from_pdf_success(self, mock_mistral):
        result = extract_text_from_pdf(b"fake-pdf")
        assert "Extracted OCR text" in result
        mock_mistral.files.upload.assert_called_once()
        mock_mistral.files.get_signed_url.assert_called_once()
        mock_mistral.ocr.process.assert_called_once()
        mock_mistral.files.delete.assert_called_once()

    def test_extract_text_from_pdf_error(self, mock_mistral):
        mock_mistral.files.upload.side_effect = Exception("API Error")
        result = extract_text_from_pdf(b"fake-pdf")
        assert result == ""

    @pytest.mark.parametrize("raw_text,expected_nama", [
        ("John Doe Python Developer", "Test User"),
        ("", "Tidak Terdeteksi"),
        ("   ", "Tidak Terdeteksi"),
    ])
    def test_process_resume(self, raw_text, expected_nama, mock_groq):
        result = process_resume_with_ai(raw_text)
        assert result["nama"] == expected_nama

    def test_process_resume_api_error(self, mock_groq):
        from unittest.mock import patch
        with patch("app.services.ai_nlp.client.chat.completions.create", side_effect=Exception("API Error")):
            result = process_resume_with_ai("Some text")
            assert result == {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": ""}

    def test_draft_project_success(self, mock_groq):
        from unittest.mock import patch, MagicMock
        import json
        mock_response = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = json.dumps({
            "judul_proyek": "AI Project",
            "deskripsi": "Build AI",
            "kategori": "Teknologi",
            "roles_dibutuhkan": [{"nama_role": "Developer", "deskripsi_tugas": "Code", "skills": ["Python"]}]
        })
        mock_response.choices = [mock_choice]

        with patch("app.services.ai_nlp.client.chat.completions.create", return_value=mock_response):
            result = draft_project_with_ai("Make an AI project")
            assert result["judul_proyek"] == "AI Project"

    def test_draft_project_empty(self):
        result = draft_project_with_ai("")
        assert result == {"error": "Ide proyek tidak boleh kosong"}

    def test_draft_project_error(self, mock_groq):
        from unittest.mock import patch
        with patch("app.services.ai_nlp.client.chat.completions.create", side_effect=Exception("Error")):
            result = draft_project_with_ai("Some idea")
            assert result == {"error": "Gagal memproses ide dengan AI"}

    def test_process_resume_removes_think_block(self, mock_groq):
        from unittest.mock import patch, MagicMock
        mock_response = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = "<think>thinking...</think>{\"nama\": \"Test\"}"
        mock_response.choices = [mock_choice]

        with patch("app.services.ai_nlp.client.chat.completions.create", return_value=mock_response):
            result = process_resume_with_ai("something")
            assert result["nama"] == "Test"

    def test_process_resume_removes_markdown(self, mock_groq):
        from unittest.mock import patch, MagicMock
        import json
        mock_response = MagicMock()
        mock_choice = MagicMock()
        mock_choice.message.content = "```json\n{\"nama\": \"Test\"}\n```"
        mock_response.choices = [mock_choice]

        with patch("app.services.ai_nlp.client.chat.completions.create", return_value=mock_response):
            result = process_resume_with_ai("something")
            assert result["nama"] == "Test"