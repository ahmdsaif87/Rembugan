import os
import json
import re
from groq import Groq
from dotenv import load_dotenv
from mistralai.client import Mistral

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
        print(f"Gagal memproses OCR: {e}")
        return ""

def process_resume_with_ai(raw_text: str):
    """
    Satu fungsi AI untuk MERAPIKAN hasil OCR yang berantakan.
    Menggunakan Groq (Qwen) sebagai Data Extractor yang disiplin.
    """
    if not raw_text.strip():
        return {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": ""}

    # PROMPT KETAT & EFISIEN
    prompt = f"""
    Ekstrak data dari teks OCR CV berikut:
    "{raw_text}"
    
    Aturan:
    1. Ambil "nama" lengkap.
    2. Ekstrak "skills" teknis penting saja dalam bentuk array string.
    3. Buat "bio_suggestion" (1-2 kalimat kasual mahasiswa/pekerja).
    
    Keluarkan HANYA JSON murni (tanpa markdown).
    Format:
    {{
        "nama": "Nama Asli",
        "skills": ["Skill 1", "Skill 2"],
        "bio_suggestion": "Bio singkat..."
    }}
    """
    
    try:
        response = client.chat.completions.create(
            model="qwen/qwen3-32b", 
            messages=[
                {"role": "system", "content": "You are a precise JSON data extractor. Output ONLY valid JSON, nothing else."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.1
        )
        
        result_text = response.choices[0].message.content.strip()
        
        # Remove <think>...</think> block if present
        result_text = re.sub(r'<think>.*?</think>', '', result_text, flags=re.DOTALL).strip()
        
        # Clean up possible markdown block just in case
        if result_text.startswith("```json"):
            result_text = result_text[7:]
        if result_text.endswith("```"):
            result_text = result_text[:-3]
            
        parsed_data = json.loads(result_text.strip())
        return parsed_data
        
    except Exception as e:
        print(f"Gagal memproses AI: {e}")
        return {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": ""}

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
    
    Keluarkan HANYA JSON murni (tanpa markdown blok).
    Format:
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
            model="qwen/qwen3-32b", 
            messages=[
                {"role": "system", "content": "You are a Project Manager AI. Output ONLY valid JSON."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.3
        )
        
        result_text = response.choices[0].message.content.strip()
        
        # Remove <think>...</think> block if present
        result_text = re.sub(r'<think>.*?</think>', '', result_text, flags=re.DOTALL).strip()
        
        if result_text.startswith("```json"):
            result_text = result_text[7:]
        if result_text.endswith("```"):
            result_text = result_text[:-3]
            
        parsed_data = json.loads(result_text.strip())
        return parsed_data
        
    except Exception as e:
        print(f"Gagal generate draft proyek: {e}")
        return {"error": "Gagal memproses ide dengan AI"}