from fastapi import FastAPI
from prisma import Prisma
from core.config import setup_cloudinary
from core.security import setup_firebase
from api import onboarding

# 1. Inisialisasi Layanan External
setup_cloudinary()
setup_firebase()

# 2. Inisialisasi Database & App
db = Prisma()
app = FastAPI(
    title="CYCLO API",
    description="Backend AI & Database untuk Mahasiswa Project System",
    version="1.0.0"
)

# 3. Lifecycle Events (Connect DB)
@app.on_event("startup")
async def startup():
    await db.connect()

@app.on_event("shutdown")
async def shutdown():
    await db.disconnect()

# 4. Daftarkan Semua Endpoint (Routers)
app.include_router(onboarding.router)
# app.include_router(auth.router) -> Nanti ditambahkan jika file auth.py sudah dibuat

@app.get("/", tags=["0. Root"])
async def root():
    return {"message": "Server MAPS Enterprise-Grade Aktif!"}