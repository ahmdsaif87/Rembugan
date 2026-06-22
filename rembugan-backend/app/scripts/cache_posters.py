import asyncio, hashlib, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))
from motor.motor_asyncio import AsyncIOMotorClient
import httpx
from dotenv import load_dotenv

load_dotenv()

POSTERS_DIR = os.path.join(os.path.dirname(__file__), "..", "static", "posters")
os.makedirs(POSTERS_DIR, exist_ok=True)

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/125.0.6422.165 Mobile Safari/537.36"
    ),
    "Accept": "image/avif,image/webp,image/apng,image/*,*/*;q=0.8",
    "Referer": "https://www.instagram.com/",
}

async def main():
    mongo_uri = os.getenv("MONGO_URI")
    if not mongo_uri:
        print("MONGO_URI not set")
        return
    client = AsyncIOMotorClient(mongo_uri)
    collection = client["competition_scraper"]["competition"]
    cursor = collection.find({})
    urls = []
    async for doc in cursor:
        url = doc.get("poster", "")
        if url:
            urls.append(url)
    print(f"Total poster URLs: {len(urls)}")
    async with httpx.AsyncClient(timeout=30, follow_redirects=True) as hx:
        for url in urls:
            url_hash = hashlib.md5(url.encode()).hexdigest()
            local = os.path.join(POSTERS_DIR, f"{url_hash}.jpg")
            if os.path.exists(local):
                print(f"  cached: {url_hash}")
                continue
            try:
                r = await hx.get(url, headers=HEADERS)
                r.raise_for_status()
                with open(local, "wb") as f:
                    f.write(r.content)
                print(f"  OK: {url_hash} ({len(r.content)} bytes)")
            except Exception as e:
                print(f"  FAIL: {url[:60]}... {e}")
    print("Done")

if __name__ == "__main__":
    asyncio.run(main())
