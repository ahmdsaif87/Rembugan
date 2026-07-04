from typing import Any


def response_success(
    data: Any = None,
    message: str = "success",
) -> dict:
    result = {"status": "success", "message": message}
    if data is not None:
        result["data"] = data
    return result


def response_error(
    detail: str,
) -> dict:
    return {"status": "error", "detail": detail}


def response_paginated(
    data: list,
    total: int,
    page: int,
    limit: int,
) -> dict:
    return {
        "status": "success",
        "page": page,
        "limit": limit,
        "total": total,
        "has_next": (page * limit) < total,
        "data": data,
    }
