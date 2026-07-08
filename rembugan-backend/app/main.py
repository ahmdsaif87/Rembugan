import os
import time
import uuid
import asyncio
import traceback
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, HTTPException
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException
from app.core.config import setup_cloudinary
from app.core.database import db
from app.core.cache import cache
from app.core.tasks import fire_and_forget
from app.core.rate_limit import limiter
from app.core.logger import setup_logging, get_logger
from app.services.embedding import preload_embedding_model

logger = get_logger("main")
setup_logging()
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.staticfiles import StaticFiles
from app.api import auth, onboarding, projects, collaboration, showcase, chat, workspace, competitions, fyp, profile, notifications, connections, upload, qr, saved, posts
from app.api.admin import router as admin_router

# Inisialisasi Layanan External
setup_cloudinary()

# Lifecycle: Connect & Disconnect Database
@asynccontextmanager
async def lifespan(app: FastAPI):
    await db.connect()
    logger.info("Database terhubung!")
    await cache.init()
    logger.info(f"Cache backend: {cache.stats()['backend']}")

    fire_and_forget(preload_embedding_model(), "preload_embedding_model")

    yield
    await cache.disconnect()
    await db.disconnect()
    logger.info("Database terputus.")

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

# Daftarkan Rate Limiter
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


# ── Global Exception Handlers ──

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={"status": "error", "detail": exc.detail},
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    detail = errors[0]["msg"] if errors else "Input tidak valid"
    return JSONResponse(
        status_code=422,
        content={"status": "error", "detail": detail, "errors": errors},
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled error: {exc}\n{traceback.format_exc()}")
    return JSONResponse(
        status_code=500,
        content={"status": "error", "detail": "Terjadi kesalahan internal server."},
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
app.include_router(upload.router)
app.include_router(qr.router)
app.include_router(saved.router)
app.include_router(posts.router)
app.include_router(admin_router)

# Serve static files (poster images, etc.)
STATIC_DIR = os.path.join(os.path.dirname(__file__), "static")
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# Middleware CORS
allowed_origins_raw = os.getenv("ALLOWED_ORIGINS", "")
if allowed_origins_raw:
    origins = [o.strip() for o in allowed_origins_raw.split(",") if o.strip()]
else:
    origins = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=[
        "Authorization", "Content-Type", "Accept",
        "Origin", "X-Requested-With", "ngrok-skip-browser-warning",
    ],
    expose_headers=["X-Request-ID"],
)

# Request body size limit — 10MB
MAX_BODY_SIZE = 10 * 1024 * 1024

@app.middleware("http")
async def request_id_and_size_limit(request: Request, call_next):
    request_id = str(uuid.uuid4())[:8]
    request.state.request_id = request_id

    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > MAX_BODY_SIZE:
        return JSONResponse(
            status_code=413,
            content={"detail": "Request body terlalu besar. Maksimal 10MB."},
        )

    start = time.time()
    response = await call_next(request)
    elapsed = (time.time() - start) * 1000
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Response-Time-Ms"] = str(int(elapsed))
    return response


@app.get("/", tags=["0. Root"])
async def root():
    return {"message": "REMBUGAN API Aktif!", "version": "1.0.0"}


@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    return JSONResponse(content=None, status_code=204)


@app.get("/healthz", tags=["0. Root"])
async def healthz():
    db_ok = False
    try:
        await db.execute_raw("SELECT 1")
        db_ok = True
    except Exception:
        db_ok = False
    return {
        "status": "healthy" if db_ok else "degraded",
        "database": "connected" if db_ok else "disconnected",
        "timestamp": time.time(),
    }