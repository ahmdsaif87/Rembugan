from datetime import datetime
from zoneinfo import ZoneInfo

TZ = ZoneInfo("Asia/Jakarta")


def tz_iso(dt: datetime) -> str:
    """Format datetime ke ISO string dengan timezone Asia/Jakarta."""
    return dt.astimezone(TZ).isoformat()
