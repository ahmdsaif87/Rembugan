import asyncio
from typing import Coroutine, Any
from app.core.logger import get_logger

logger = get_logger("tasks")


def fire_and_forget(coro: Coroutine[Any, Any, Any], name: str = "background_task"):
    """Run a coroutine in the background with error logging.

    Use this instead of raw asyncio.create_task() to ensure errors are logged.
    """
    task = asyncio.create_task(coro, name=name)

    def _done_callback(fut: asyncio.Task):
        try:
            exc = fut.exception()
            if exc:
                logger.error(f"Background task '{name}' failed: {exc}")
        except asyncio.CancelledError:
            logger.warning(f"Background task '{name}' was cancelled")

    task.add_done_callback(_done_callback)
    return task
