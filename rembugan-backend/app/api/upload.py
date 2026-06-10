from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from app.core.security import verify_token
from app.services.storage import upload_image_to_cloudinary

router = APIRouter(prefix="/upload", tags=["Upload Media"])

@router.post("/image", summary="Upload Gambar ke Cloudinary")
async def upload_image(
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File harus berupa gambar")

    image_bytes = await file.read()
    url = upload_image_to_cloudinary(image_bytes, folder_name="rembugan_uploads")

    return {
        "status": "success",
        "data": {"url": url, "filename": file.filename},
    }
