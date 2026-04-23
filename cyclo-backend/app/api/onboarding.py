from fastapi import APIRouter, UploadFile, File, HTTPException
from services.ai_vision import extract_photo_from_pdf
from services.storage import upload_image_to_cloudinary

router = APIRouter(prefix="/onboarding", tags=["2. AI & Onboarding"])

@router.post("/extract-cv", summary="Ekstrak Foto Asli dari CV")
async def extract_cv_data(file: UploadFile = File(...)):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Format file harus PDF!")
    
    file_bytes = await file.read()
    
    # Panggil fungsi ekstraksi foto dari PDF
    photo_bytes = extract_photo_from_pdf(file_bytes)
    
    if not photo_bytes:
        return {
            "status": "partial_success",
            "message": "File PDF tidak mengandung elemen foto.",
            "photo_url": None
        }
        
    # Upload ke Cloudinary
    photo_url = upload_image_to_cloudinary(photo_bytes)
    
    return {
        "status": "success",
        "message": "Foto asli berhasil diekstrak dan diunggah!",
        "photo_url": photo_url
    }