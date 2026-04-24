import fitz
from fastapi import HTTPException

def extract_photo_from_pdf(pdf_bytes: bytes) -> bytes:
    try:
        # 1. Buka file PDF
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
        page = doc[0]
        
        # 3. Cari semua elemen "Gambar" yang menempel di halaman tersebut
        image_list = page.get_images(full=True)
        
        if not image_list:  
            return None
            
        # 4. Ambil gambar pertama yang ditemukan
        xref = image_list[0][0]
        
        # Ekstrak gambar asli berdasarkan ID tersebut
        base_image = doc.extract_image(xref)
        image_bytes = base_image["image"] 
        
        return image_bytes

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error ekstraksi foto: {str(e)}")