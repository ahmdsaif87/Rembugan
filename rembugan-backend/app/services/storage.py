import asyncio
import cloudinary.uploader
from fastapi import HTTPException


def _upload_to_cloudinary(image_bytes: bytes, folder_name: str = "rembugan_user_profiles") -> str:
    """Sync wrapper — dipanggil via run_in_executor."""
    try:
        result = cloudinary.uploader.upload(image_bytes, folder=folder_name, resource_type="auto")
        return result.get("secure_url")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Gagal upload ke Cloudinary: {str(e)}")


async def upload_image_to_cloudinary(
    image_bytes: bytes, folder_name: str = "rembugan_user_profiles"
) -> str:
    """Async version — tidak blocking event loop."""
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(
        None, _upload_to_cloudinary, image_bytes, folder_name
    )
