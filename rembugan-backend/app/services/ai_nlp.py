import os
import json
import numpy as np
from rapidocr_onnxruntime import RapidOCR
from pdf2image import convert_from_bytes
from google import genai
from dotenv import load_dotenv

load_dotenv()
client = genai.Client()

print("Memuat model RapidOCR (Super Ringan)...")
engine = RapidOCR()

def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """Membaca teks dari PDF (termasuk hasil scan) menggunakan RapidOCR."""
    try:
        images = convert_from_bytes(pdf_bytes)
        full_text = []
        for img in images:
            img_np = np.array(img)
            result, elapse = engine(img_np)
            if result:
                for item in result:
                    full_text.append(item[1]) 
        return "\n".join(full_text)
    except Exception as e:
        print(f"Gagal memproses OCR: {e}")
        return ""

def process_resume_with_gemini(raw_text: str):
    """
    Satu fungsi AI untuk MERAPIKAN hasil OCR yang berantakan.
    Gemini dipaksa bertindak sebagai Data Extractor yang disiplin.
    """
    if not raw_text.strip():
        return {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": ""}

    # PROMPT KETAT: Paksa AI agar cuma nge-list, bukan ngarang!
    prompt = f"""
    Kamu adalah sistem Data Extraction yang sangat presisi. 
    Teks di bawah ini adalah hasil OCR dari sebuah CV yang mungkin berantakan:
    
    "{raw_text}"
    
    Tugasmu:
    1. Cari dan ekstrak NAMA LENGKAP kandidat (Hanya nama orang, BUKAN judul seperti 'Ringkasan' atau 'Curriculum Vitae').
    2. Cari dan ekstrak HANYA kata kunci skill/keahliannya (Misal: "Pengelasan MIG", "TIG", "AutoCAD"). JANGAN masukkan kalimat deskripsi panjang atau pengalaman kerja ke dalam array skills!
    3. Buatkan satu paragraf bio singkat (maksimal 3 kalimat) dengan bahasa Indonesia yang kasual khas mahasiswa/pekerja lapangan.
    
    Kembalikan output HANYA dalam format JSON murni tanpa markdown (```json):
    {{
        "nama": "Nama Asli Orang",
        "skills": ["Skill 1", "Skill 2"],
        "bio_suggestion": "Teks bio yang kamu buat..."
    }}
    """
    
    try:
        response = client.models.generate_content(
            model="gemini-3-flash-preview", 
            contents=prompt
        )
        
        result_text = response.text.replace("```json", "").replace("```", "").strip()
        parsed_data = json.loads(result_text)
        return parsed_data
        
    except Exception as e:
        print(f"Gagal memproses AI: {e}")
        return {"nama": "Tidak Terdeteksi", "skills": [], "bio_suggestion": ""}

def draft_project_with_gemini(ide_kasar: str) -> dict:
    """
    Menyulap ide kasar proyek mahasiswa menjadi spesifikasi proyek profesional
    yang siap di-posting di aplikasi CollabFinder.
    """
    if not ide_kasar.strip():
        return {"error": "Ide proyek tidak boleh kosong"}

    prompt = f"""
    Kamu adalah Project Manager profesional. Ada seorang mahasiswa yang ingin mencari partner untuk proyeknya. 
    Ini adalah ide kasarnya: "{ide_kasar}"
    
    Tugasmu adalah merapikan ide tersebut menjadi sebuah draf lowongan proyek (Project Offering) yang menarik.
    
    Kembalikan output HANYA dalam format JSON murni persis seperti ini (tanpa markdown blok):
    {{
        "judul_proyek": "Beri judul yang *catchy* dan profesional",
        "deskripsi": "Deskripsi proyek 1-2 paragraf yang jelas, menarik, dan kasual khas mahasiswa",
        "kategori": "Pilih satu: [Teknologi, Riset, Bisnis, Desain, Sosial]",
        "roles_dibutuhkan": [
            {{
                "nama_role": "Misal: UI/UX Designer",
                "deskripsi_tugas": "Apa yang harus dia kerjakan",
                "skills": ["Figma", "Wireframing", "User Research"]
            }},
            {{
                "nama_role": "Misal: Backend Developer",
                "deskripsi_tugas": "Apa yang harus dia kerjakan",
                "skills": ["FastAPI", "PostgreSQL", "Python"]
            }}
        ]
    }}
    """
    
    try:
        response = client.models.generate_content(
            model="gemini-3-flash-preview", 
            contents=prompt
        )
        
        result_text = response.text.replace("```json", "").replace("```", "").strip()
        parsed_data = json.loads(result_text)
        return parsed_data
        
    except Exception as e:
        print(f"Gagal generate draft proyek: {e}")
        return {"error": "Gagal memproses ide dengan AI"}