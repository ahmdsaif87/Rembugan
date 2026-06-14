import os
from motor.motor_asyncio import AsyncIOMotorClient

_client = None
_collection = None


def _get_client():
    global _client
    if _client is None:
        uri = os.getenv("MONGO_URI")
        if uri:
            _client = AsyncIOMotorClient(uri)
    return _client


def get_competition_collection():
    """Lazy MongoDB collection — tidak connect sampai dipanggil."""
    global _collection
    if _collection is None:
        client = _get_client()
        if client is not None:
            _collection = client["competition_scraper"]["competition"]
    return _collection
