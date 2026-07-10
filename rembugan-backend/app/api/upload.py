from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Request
from app.core.response import response_success
from app.core.security import verify_token
from app.core.rate_limit import limiter
from app.services.storage import upload_image_to_cloudinary

router = APIRouter(prefix="/upload", tags=["Upload Media"])

ALLOWED_IMAGE_EXTENSIONS = {".jpeg", ".jpg", ".png", ".webp", ".gif"}
ALLOWED_DOC_EXTENSIONS = {".pdf", ".doc", ".docx", ".txt", ".xls", ".xlsx"}


@router.post("/image", summary="Upload Gambar")
@limiter.limit("5/minute")
async def upload_image(
    request: Request,
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
):
    ext = (file.filename or "").lower()
    if not any(ext.endswith(e) for e in ALLOWED_IMAGE_EXTENSIONS):
        raise HTTPException(status_code=400, detail="File harus berupa gambar (jpeg/png/webp/gif)")

    image_bytes = await file.read()
    url = await upload_image_to_cloudinary(image_bytes, folder_name="rembugan_uploads")

    return response_success({"url": url, "filename": file.filename, "type": "image"})


@router.post("/file", summary="Upload Dokumen")
@limiter.limit("5/minute")
async def upload_document(
    request: Request,
    file: UploadFile = File(...),
    user_token: dict = Depends(verify_token),
):
    ext = (file.filename or "").lower()
    if not any(ext.endswith(e) for e in ALLOWED_DOC_EXTENSIONS):
        raise HTTPException(
            status_code=400,
            detail="File harus berupa dokumen (pdf/doc/docx/txt/xls/xlsx)",
        )

    content = await file.read()
    url = await upload_image_to_cloudinary(content, folder_name="rembugan_documents")

    size_kb = len(content) / 1024
    size_str = f"{size_kb:.0f} KB" if size_kb < 1024 else f"{size_kb / 1024:.1f} MB"

    return response_success({
        "url": url,
        "filename": file.filename,
        "size": size_str,
        "type": "document",
    })
