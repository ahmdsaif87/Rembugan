import os
from dotenv import load_dotenv
import cloudinary

# Muat file .env dari folder root
load_dotenv()

# Konfigurasi Cloudinary
def setup_cloudinary():
    cloudinary.config(
        cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
        api_key=os.getenv("CLOUDINARY_API_KEY"),
        api_secret=os.getenv("CLOUDINARY_API_SECRET")
    )