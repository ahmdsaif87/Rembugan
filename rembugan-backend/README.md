# Rembugan Backend

The backend API for the Rembugan platform, built with **FastAPI**, **Prisma (PostgreSQL)**, **MongoDB**, and powered by AI services like **Gemini AI**.

## Prerequisites
- Python 3.9+
- PostgreSQL
- MongoDB
- Cloudinary Account (for media storage)
- Resend Account (for email services)

## Local Setup

1. Create a virtual environment & install dependencies:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

2. Setup Environment Variables:
   Create a `.env` file in the root backend folder and add the following configurations:
   - `DATABASE_URL` (PostgreSQL)
   - `MONGODB_URL`
   - `CLOUDINARY_URL`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
   - `GEMINI_API_KEY`
   - Other credentials as needed.
   
   *Note:* Ensure the `firebase-admin.json` file is also placed in the root backend folder for notification/authentication services.

3. Database Synchronization (Prisma):
   ```bash
   prisma generate
   prisma db push
   ```

4. Run the Server:
   ```bash
   uvicorn app.main:app --reload
   ```
   
Access the API documentation (Swagger UI) at: `http://127.0.0.1:8000/docs`
