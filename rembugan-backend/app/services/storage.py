import cloudinary.uploader
from fastapi import HTTPException

def upload_image_to_cloudinary(image_bytes: bytes, folder_name: str = "rembugan_user_profiles") -> str:
    try:
        result = cloudinary.uploader.upload(image_bytes, folder=folder_name)
        return result.get("secure_url")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal upload ke Cloudinary: {str(e)}")