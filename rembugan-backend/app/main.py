from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.core.config import setup_cloudinary
from app.core.security import setup_firebase
from app.core.database import db
from app.api import auth, onboarding, projects, collaboration, showcase, chat, workspace

# 1. Inisialisasi Layanan External
setup_cloudinary()
setup_firebase()

# 2. Lifecycle: Connect & Disconnect Database
@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.connect()
    print("✅ Database terhubung!")
    yield
    await db.disconnect()
    print("🔌 Database terputus.")

# 3. Inisialisasi App
app = FastAPI(
    title="REMBUGAN API",
    description=(
        "REMBUGAN adalah platform kolaborasi proyek yang menghubungkan individu berbakat "
        "dengan peluang proyek yang sesuai. API ini menyediakan endpoint untuk rembugan."
    ),
    version="1.0.0",
    lifespan=lifespan,
)

# 4. Daftarkan Semua Endpoint (Routers)
app.include_router(auth.router)
app.include_router(onboarding.router)
app.include_router(projects.router)
app.include_router(collaboration.router)
app.include_router(showcase.router)
app.include_router(chat.router)
app.include_router(workspace.router)


@app.get("/", tags=["0. Root"])
async def root():
    return {"message": "REMBUGAN API Aktif!", "version": "1.0.0"}