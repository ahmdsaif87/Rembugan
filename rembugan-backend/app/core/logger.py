import logging
import sys

FORMAT = "[%(asctime)s] %(levelname)s %(name)s: %(message)s"
DATEFMT = "%Y-%m-%d %H:%M:%S"


def setup_logging():
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter(FORMAT, DATEFMT))
    logging.basicConfig(level=logging.INFO, handlers=[handler], force=True)


def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
