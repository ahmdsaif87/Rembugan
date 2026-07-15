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
from app.core.database_sql import engine as sql_engine, close_engine
from app.core.cache import cache
from app.core.tasks import fire_and_forget
from app.core.rate_limit import limiter
from app.core.logger import setup_logging, get_logger

logger = get_logger("main")
setup_logging()
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.api import auth, onboarding, projects, collaboration, showcase, chat, workspace, competitions, fyp, profile, notifications, connections, upload, qr, saved, posts
from app.api.admin import router as admin_router



# Inisialisasi Layanan External
setup_cloudinary()

# Lifecycle: Connect & Disconnect Database
@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        from sqlalchemy import text
        async with sql_engine.begin() as conn:
            await conn.execute(text("SELECT 1"))
            await conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
            for tbl in ("User", "Project", "Showcase"):
                try:
                    await conn.execute(
                        text(f'ALTER TABLE "{tbl}" ALTER COLUMN embedding TYPE vector(384) USING embedding::text::vector')
                    )
                except Exception:
                    pass
        logger.info("Database terhubung (SQLAlchemy)!")
    except Exception as e:
        logger.error(f"Gagal konek database: {e}")
        raise
    await cache.init()
    logger.info(f"Cache backend: {cache.stats()['backend']}")

    yield
    await cache.disconnect()
    await close_engine()
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


# ── Global Exception Handler (single) ──

@app.exception_handler(Exception)
async def unified_exception_handler(request: Request, exc: Exception):
    if isinstance(exc, (StarletteHTTPException, HTTPException)):
        status = exc.status_code
        detail = exc.detail
    elif isinstance(exc, RequestValidationError):
        errors = exc.errors()
        return JSONResponse(
            status_code=422,
            content={"status": "error", "detail": errors[0]["msg"] if errors else "Input tidak valid", "errors": errors},
        )
    elif isinstance(exc, RateLimitExceeded):
        return JSONResponse(
            status_code=429,
            content={"status": "error", "detail": "Terlalu banyak permintaan. Silakan coba lagi nanti."},
        )
    else:
        status = 500
        detail = "Terjadi kesalahan internal server."
        logger.error(f"Unhandled: {exc}\n{traceback.format_exc()}")

    return JSONResponse(status_code=status, content={"status": "error", "detail": detail})


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