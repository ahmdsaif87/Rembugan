from prisma import Prisma

# Singleton instance — satu koneksi untuk seluruh aplikasi
db = Prisma()

async def get_db() -> Prisma:
    """FastAPI Dependency: Inject Prisma client ke setiap route."""
    return db
