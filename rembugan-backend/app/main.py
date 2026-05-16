from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.core.config import setup_cloudinary
from app.core.security import setup_firebase
from app.core.database import db
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, onboarding, projects, collaboration, showcase, chat, workspace, competitions, fyp, profile, notifications, connections
from app.api.admin import router as admin_router

# Inisialisasi Layanan External
setup_cloudinary()
setup_firebase()

# Lifecycle: Connect & Disconnect Database
@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.connect()
    print("Database terhubung!")
    yield
    await db.disconnect()
    print("Database terputus.")

# Inisialisasi App
app = FastAPI(
    title="REMBUGAN API",
    description=(
        "REMBUGAN adalah platform kolaborasi proyek yang menghubungkan individu berbakat "
        "dengan peluang proyek yang sesuai. API ini menyediakan endpoint untuk rembugan."
    ),
    version="1.0.0",
    lifespan=lifespan,
)

# Daftarkan Semua Endpoint
app.include_router(auth.router)
app.include_router(onboarding.router)
app.include_router(projects.router)
app.include_router(collaboration.router)
app.include_router(showcase.router)
app.include_router(chat.router)
app.include_router(workspace.router)
app.include_router(competitions.router)
app.include_router(fyp.router)
app.include_router(profile.router)
app.include_router(notifications.router)
app.include_router(connections.router)
app.include_router(admin_router)

# Middleware CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/", tags=["0. Root"])
async def root():
    return {"message": "REMBUGAN API Aktif!", "version": "1.0.0"}