from typing import Final

# ── Project ──
PJ_OPEN: Final = "open"
PJ_ONGOING: Final = "ongoing"
PJ_COMPLETED: Final = "completed"
PJ_STATUSES: Final = [PJ_OPEN, PJ_ONGOING, PJ_COMPLETED]

# ── Application ──
APP_PENDING: Final = "pending"
APP_ACCEPTED: Final = "accepted"
APP_REJECTED: Final = "rejected"
APP_STATUSES: Final = [APP_PENDING, APP_ACCEPTED, APP_REJECTED]

# ── Task ──
TASK_TODO: Final = "todo"
TASK_DOING: Final = "doing"
TASK_DONE: Final = "done"
TASK_STATUSES: Final = [TASK_TODO, TASK_DOING, TASK_DONE]

# ── Member Role ──
ROLE_KETUA: Final = "Ketua"
ROLE_ANGGOTA: Final = "Anggota"
ROLES: Final = [ROLE_KETUA, ROLE_ANGGOTA]

# ── Connection ──
CON_PENDING: Final = "pending"
CON_ACCEPTED: Final = "accepted"
CON_REJECTED: Final = "rejected"

# ── Notification Type ──
NOTIF_LIKE: Final = "like"
NOTIF_COMMENT: Final = "comment"
NOTIF_CHAT: Final = "chat"
NOTIF_GROUP_TAG: Final = "group_chat_tag"
NOTIF_CONN_REQUEST: Final = "connection_request"
NOTIF_CONN_ACCEPTED: Final = "connection_accepted"
NOTIF_APPLICATION_RECEIVED: Final = "application_received"
NOTIF_APPLICATION_ACCEPTED: Final = "application_accepted"
NOTIF_APPLICATION_REJECTED: Final = "application_rejected"
NOTIF_TASK_ASSIGNED: Final = "task_assigned"
NOTIF_DEADLINE_REMINDER: Final = "deadline_reminder"
NOTIF_FILE_UPLOADED: Final = "file_uploaded"
NOTIF_ROLE_APPROVED: Final = "role_approved"

# ── Auth ──
ROLE_ADMIN: Final = "admin"
OTP_MAX_PER_HOUR: Final = 3
OTP_EXPIRY_MINUTES: Final = 5
OTP_MAX_ATTEMPTS: Final = 3

# ── Limits ──
EXPLORE_MAX_ROWS: Final = 1000
FYP_MAX_ROWS: Final = 500
CHAT_HISTORY_MAX: Final = 200
MAX_BODY_SIZE: Final = 10 * 1024 * 1024  # 10 MB
