import os
from app.core.logger import get_logger

logger = get_logger(__name__)

_admin_sdk = None

def _get_app():
    global _admin_sdk
    if _admin_sdk is not None:
        return _admin_sdk
    try:
        import firebase_admin
        from firebase_admin import credentials

        cred_json = os.getenv("FCM_CREDENTIALS_JSON")
        if cred_json:
            import json
            cred = credentials.Certificate(json.loads(cred_json))
            _admin_sdk = firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin SDK initialized from env var")
        else:
            path = os.getenv("FCM_CREDENTIALS_PATH", "firebase-admin.json")
            if os.path.exists(path):
                cred = credentials.Certificate(path)
                _admin_sdk = firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK initialized from file")
            else:
                logger.warning(f"FCM credentials not found at {path}")
        return _admin_sdk
    except Exception as e:
        logger.warning(f"Firebase Admin SDK not available: {e}")
        return None


async def send_push_notification(
    token: str,
    title: str,
    body: str,
    data: dict | None = None,
):
    app = _get_app()
    if app is None:
        logger.debug("FCM not configured, skipping push")
        return
    try:
        from firebase_admin import messaging
        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=token,
        )
        response = messaging.send(message)
        logger.debug(f"FCM sent: {response}")
    except Exception as e:
        logger.error(f"FCM send failed: {e}")


async def send_multicast_push(
    tokens: list[str],
    title: str,
    body: str,
    data: dict | None = None,
):
    app = _get_app()
    if app is None or not tokens:
        return
    try:
        from firebase_admin import messaging
        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            tokens=tokens,
        )
        response = messaging.send_each_for_multicast(message)
        logger.debug(f"FCM multicast: {response.success_count}/{len(tokens)} sent")
    except Exception as e:
        logger.error(f"FCM multicast failed: {e}")
