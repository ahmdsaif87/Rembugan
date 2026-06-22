import os
import json
import re
from groq import Groq
from dotenv import load_dotenv
from mistralai.client import Mistral
from app.core.logger import get_logger

logger = get_logger(__name__)

load_dotenv()
client = Groq(api_key=os.getenv("GROQ_API_KEY"))
mistral_client = Mistral(api_key=os.getenv("MISTRAL_API_KEY"))

def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """Membaca teks dari PDF (termasuk hasil scan) menggunakan Mistral OCR."""
    try:
        uploaded_file = mistral_client.files.upload(
            file={
                "file_name": "document.pdf",
                "content": pdf_bytes,
            },
            purpose="ocr"
        )

        signed_url = mistral_client.files.get_signed_url(file_id=uploaded_file.id)

        ocr_response = mistral_client.ocr.process(
            model="mistral-ocr-latest",
            document={
                "type": "document_url",
                "document_url": signed_url.url,
            }
        )

        full_text = [page.markdown for page in ocr_response.pages]

        mistral_client.files.delete(file_id=uploaded_file.id)

        return "\n\n".join(full_text)
    except Exception as e:
        logger.exception("Gagal memproses OCR")
        return ""

def _clean_json_response(text: str) -> str:
    text = re.sub(r"<think>.*?</think>", "", text, flags=re.DOTALL)
    text = re.sub(r"^```(?:json)?\s*", "", text)
    text = re.sub(r"\s*```$", "", text)
    return text.strip()

def process_resume_with_ai(raw_text: str):
    """
    Satu fungsi AI untuk MERAPIKAN hasil OCR yang berantakan.
    Menggunakan Groq (Llama) dengan response_format=json_object.
    """
    if not raw_text.strip():
        return {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": "", "experiences": []}

    prompt = f"""
Ekstrak data dari teks OCR CV berikut:
"{raw_text}"

Aturan:
1. Ambil "nama" lengkap.
2. Ekstrak "skills" teknis penting saja dalam bentuk array string.
3. Buat "bio_suggestion" bergaya LinkedIn: 2-3 kalimat profesional tentang keahlian utama, fokus pengembangan, dan nilai yang bisa ditawarkan. Bukan terlalu singkat (1 kalimat) dan bukan terlalu panjang (lebih dari 3 kalimat). Gunakan nada bicara yang confident tapi tetap humble, seperti bio profesional di LinkedIn.
4. Ekstrak "experiences" dari CV: setiap pengalaman kerja, organisasi, atau proyek yang disebutkan. Jika tidak ada pengalaman yang terdeteksi, kembalikan array kosong [].

Format:
{{
    "nama": "Nama Asli",
    "skills": ["Skill 1", "Skill 2"],
    "bio_suggestion": "Bio LinkedIn 2-3 kalimat...",
    "experiences": [
        {{
            "title": "Judul Posisi / Role",
            "organization": "Nama Organisasi / Perusahaan / Proyek",
            "duration": "Periode (contoh: Feb 2025 - Jun 2025)",
            "description": "Deskripsi singkat tanggung jawab atau pencapaian",
            "tech_stack": ["Teknologi 1", "Teknologi 2"]
        }}
    ]
}}
"""
    
    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": "You are a precise JSON resume data extractor for university students."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.1
        )
        
        result_text = response.choices[0].message.content.strip()
        logger.info("AI response: %s", result_text[:300])

        result_text = _clean_json_response(result_text)
        parsed_data = json.loads(result_text)
        return parsed_data
        
    except Exception as e:
        logger.exception("Gagal memproses AI")
        return {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": "", "experiences": []}

def draft_project_with_ai(ide_kasar: str) -> dict:
    """
    Menyulap ide kasar proyek mahasiswa menjadi spesifikasi proyek profesional
    menggunakan Groq (Qwen).
    """
    if not ide_kasar.strip():
        return {"error": "Ide proyek tidak boleh kosong"}

    prompt = f"""
Rerapikan ide proyek ini menjadi lowongan yang profesional:
"{ide_kasar}"

Format JSON:
{{
    "judul_proyek": "Judul menarik",
    "deskripsi": "Deskripsi singkat, kasual",
    "kategori": "[Teknologi, Riset, Bisnis, Desain, Sosial]",
    "roles_dibutuhkan": [
        {{
            "nama_role": "Nama Peran",
            "deskripsi_tugas": "Tugas utama",
            "skills": ["Skill 1", "Skill 2"]
        }}
    ]
}}
"""
    
    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": "You are a Project Manager AI that outputs structured JSON."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3
        )
        
        result_text = response.choices[0].message.content.strip()
        result_text = _clean_json_response(result_text)
        parsed_data = json.loads(result_text)
        return parsed_data
        
    except Exception as e:
        logger.exception("Gagal generate draft proyek")
        return {"error": "Gagal memproses ide dengan AI"}