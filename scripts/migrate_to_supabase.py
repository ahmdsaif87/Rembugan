#!/usr/bin/env python3
"""
Migrate from Neon (Prisma/PostgreSQL) to Supabase (PostgreSQL + pgvector).

Usage:
    export NEON_DATABASE_URL="postgresql://..."
    export SUPABASE_URL="postgresql://..."
    python scripts/migrate_to_supabase.py
"""

import asyncio
import json
import os
import sys

import asyncpg


# ── Helpers ─────────────────────────────────────────────────────────────────

def parse_embedding(val):
    """Parse any embedding representation into a list of floats."""
    if val is None:
        return None
    if isinstance(val, (list, tuple)):
        return [float(x) for x in val]
    if isinstance(val, str):
        try:
            return json.loads(val)
        except (json.JSONDecodeError, TypeError):
            pass
    return None


def format_embedding(val):
    """Convert embedding value to Supabase vector string [0.1,0.2,...]."""
    emb = parse_embedding(val)
    if emb is None:
        return None
    return f'[{",".join(str(x) for x in emb)}]'


def prepare_row(row, vector_columns):
    """Transform source row for insertion: convert vector columns to string."""
    result = dict(row)
    for col in vector_columns:
        if col in result:
            result[col] = format_embedding(result[col])
    return result


# ── Table definitions ──────────────────────────────────────────────────────
# Order respects FK dependencies (parents before children).

TABLES = [
    {
        "name": "User",
        "create": """
            CREATE TABLE IF NOT EXISTS "User" (
                id TEXT PRIMARY KEY,
                email TEXT UNIQUE,
                password TEXT NOT NULL,
                email_verified BOOLEAN NOT NULL DEFAULT FALSE,
                nim TEXT UNIQUE,
                faculty TEXT,
                major TEXT,
                full_name TEXT NOT NULL,
                handle TEXT UNIQUE,
                bio TEXT,
                interest TEXT,
                photo_url TEXT,
                cover_url TEXT,
                social_links JSONB,
                is_onboarded BOOLEAN NOT NULL DEFAULT FALSE,
                is_admin BOOLEAN NOT NULL DEFAULT FALSE,
                embedding vector(384),
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                updated_at TIMESTAMPTZ NOT NULL
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_user_created_at ON "User" (created_at);',
            'CREATE INDEX IF NOT EXISTS idx_user_embedding ON "User" USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);',
        ],
        "columns": [
            "id", "email", "password", "email_verified", "nim", "faculty",
            "major", "full_name", "handle", "bio", "interest", "photo_url",
            "cover_url", "social_links", "is_onboarded", "is_admin",
            "embedding", "created_at", "updated_at",
        ],
        "vector_columns": ["embedding"],
        "conflict": "id",
    },
    {
        "name": "OtpCode",
        "create": """
            CREATE TABLE IF NOT EXISTS "OtpCode" (
                id SERIAL PRIMARY KEY,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                email TEXT NOT NULL,
                code_hash TEXT NOT NULL,
                expires_at TIMESTAMPTZ NOT NULL,
                attempts INTEGER NOT NULL DEFAULT 0,
                used BOOLEAN NOT NULL DEFAULT FALSE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_otpcode_user_id ON "OtpCode" (user_id);',
            'CREATE INDEX IF NOT EXISTS idx_otpcode_email ON "OtpCode" (email);',
        ],
        "columns": ["id", "user_id", "email", "code_hash", "expires_at", "attempts", "used", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "Skill",
        "create": """
            CREATE TABLE IF NOT EXISTS "Skill" (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL UNIQUE
            );
        """,
        "indexes": [],
        "columns": ["id", "name"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "UserSkill",
        "create": """
            CREATE TABLE IF NOT EXISTS "UserSkill" (
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                skill_id INTEGER NOT NULL REFERENCES "Skill"(id) ON DELETE CASCADE,
                PRIMARY KEY (user_id, skill_id)
            );
        """,
        "indexes": [],
        "columns": ["user_id", "skill_id"],
        "vector_columns": [],
        "conflict": "user_id, skill_id",
    },
    {
        "name": "Experience",
        "create": """
            CREATE TABLE IF NOT EXISTS "Experience" (
                id SERIAL PRIMARY KEY,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                title TEXT NOT NULL,
                company TEXT NOT NULL,
                description TEXT,
                start_date TIMESTAMPTZ NOT NULL,
                end_date TIMESTAMPTZ
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_experience_user_id ON "Experience" (user_id);',
        ],
        "columns": ["id", "user_id", "title", "company", "description", "start_date", "end_date"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "Project",
        "create": """
            CREATE TABLE IF NOT EXISTS "Project" (
                id SERIAL PRIMARY KEY,
                owner_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                required_skills TEXT[] DEFAULT '{}',
                status TEXT NOT NULL DEFAULT 'open',
                category TEXT,
                deadline TIMESTAMPTZ,
                total_slots INTEGER,
                embedding vector(384),
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_project_status ON "Project" (status);',
            'CREATE INDEX IF NOT EXISTS idx_project_owner_id ON "Project" (owner_id);',
            'CREATE INDEX IF NOT EXISTS idx_project_category ON "Project" (category);',
            'CREATE INDEX IF NOT EXISTS idx_project_deadline ON "Project" (deadline);',
            'CREATE INDEX IF NOT EXISTS idx_project_created_at ON "Project" (created_at);',
            'CREATE INDEX IF NOT EXISTS idx_project_embedding ON "Project" USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);',
        ],
        "columns": ["id", "owner_id", "title", "description", "required_skills", "status", "category", "deadline", "total_slots", "embedding", "created_at"],
        "vector_columns": ["embedding"],
        "conflict": "id",
    },
    {
        "name": "ProjectApplication",
        "create": """
            CREATE TABLE IF NOT EXISTS "ProjectApplication" (
                id SERIAL PRIMARY KEY,
                project_id INTEGER NOT NULL REFERENCES "Project"(id) ON DELETE CASCADE,
                applicant_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                status TEXT NOT NULL DEFAULT 'pending',
                applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_projectapp_project_status ON "ProjectApplication" (project_id, status);',
            'CREATE INDEX IF NOT EXISTS idx_projectapp_applicant ON "ProjectApplication" (applicant_id);',
        ],
        "columns": ["id", "project_id", "applicant_id", "status", "applied_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "ProjectMember",
        "create": """
            CREATE TABLE IF NOT EXISTS "ProjectMember" (
                id SERIAL PRIMARY KEY,
                project_id INTEGER NOT NULL REFERENCES "Project"(id) ON DELETE CASCADE,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                role TEXT NOT NULL DEFAULT 'Anggota'
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_projectmember_project ON "ProjectMember" (project_id);',
            'CREATE INDEX IF NOT EXISTS idx_projectmember_user ON "ProjectMember" (user_id);',
        ],
        "columns": ["id", "project_id", "user_id", "role"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "ProjectInvite",
        "create": """
            CREATE TABLE IF NOT EXISTS "ProjectInvite" (
                id TEXT PRIMARY KEY,
                project_id INTEGER NOT NULL REFERENCES "Project"(id) ON DELETE CASCADE,
                token TEXT NOT NULL UNIQUE,
                created_by TEXT NOT NULL,
                expires_at TIMESTAMPTZ NOT NULL,
                is_active BOOLEAN NOT NULL DEFAULT TRUE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [],
        "columns": ["id", "project_id", "token", "created_by", "expires_at", "is_active", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "Showcase",
        "create": """
            CREATE TABLE IF NOT EXISTS "Showcase" (
                id TEXT PRIMARY KEY,
                author_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                content TEXT NOT NULL,
                media_urls TEXT[] DEFAULT '{}',
                tags TEXT[] DEFAULT '{}',
                linked_project_id INTEGER REFERENCES "Project"(id) ON DELETE SET NULL,
                embedding vector(384),
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_showcase_author ON "Showcase" (author_id);',
            'CREATE INDEX IF NOT EXISTS idx_showcase_created_at ON "Showcase" (created_at);',
            'CREATE INDEX IF NOT EXISTS idx_showcase_embedding ON "Showcase" USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);',
        ],
        "columns": ["id", "author_id", "content", "media_urls", "tags", "linked_project_id", "embedding", "created_at"],
        "vector_columns": ["embedding"],
        "conflict": "id",
    },
    {
        "name": "ShowcaseLike",
        "create": """
            CREATE TABLE IF NOT EXISTS "ShowcaseLike" (
                id SERIAL PRIMARY KEY,
                showcase_id TEXT NOT NULL REFERENCES "Showcase"(id) ON DELETE CASCADE,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (showcase_id, user_id)
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_showcaselike_showcase ON "ShowcaseLike" (showcase_id);',
        ],
        "columns": ["id", "showcase_id", "user_id", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "ShowcaseComment",
        "create": """
            CREATE TABLE IF NOT EXISTS "ShowcaseComment" (
                id SERIAL PRIMARY KEY,
                showcase_id TEXT NOT NULL REFERENCES "Showcase"(id) ON DELETE CASCADE,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                content TEXT NOT NULL,
                parent_id INTEGER REFERENCES "ShowcaseComment"(id) ON DELETE CASCADE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_showcasecomment_showcase ON "ShowcaseComment" (showcase_id);',
            'CREATE INDEX IF NOT EXISTS idx_showcasecomment_user ON "ShowcaseComment" (user_id);',
        ],
        "columns": ["id", "showcase_id", "user_id", "content", "parent_id", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "SavedItem",
        "create": """
            CREATE TABLE IF NOT EXISTS "SavedItem" (
                id SERIAL PRIMARY KEY,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                project_id INTEGER REFERENCES "Project"(id) ON DELETE CASCADE,
                showcase_id TEXT REFERENCES "Showcase"(id) ON DELETE CASCADE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (user_id, project_id),
                UNIQUE (user_id, showcase_id)
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_saveditem_user ON "SavedItem" (user_id);',
        ],
        "columns": ["id", "user_id", "project_id", "showcase_id", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "Task",
        "create": """
            CREATE TABLE IF NOT EXISTS "Task" (
                id SERIAL PRIMARY KEY,
                project_id INTEGER NOT NULL REFERENCES "Project"(id) ON DELETE CASCADE,
                title TEXT NOT NULL,
                status TEXT NOT NULL DEFAULT 'todo',
                deadline TIMESTAMPTZ,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_task_project_status ON "Task" (project_id, status);',
        ],
        "columns": ["id", "project_id", "title", "status", "deadline", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "TaskAssignee",
        "create": """
            CREATE TABLE IF NOT EXISTS "TaskAssignee" (
                task_id INTEGER NOT NULL REFERENCES "Task"(id) ON DELETE CASCADE,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                PRIMARY KEY (task_id, user_id)
            );
        """,
        "indexes": [],
        "columns": ["task_id", "user_id"],
        "vector_columns": [],
        "conflict": "task_id, user_id",
    },
    {
        "name": "Message",
        "create": """
            CREATE TABLE IF NOT EXISTS "Message" (
                id SERIAL PRIMARY KEY,
                content TEXT NOT NULL,
                type TEXT NOT NULL DEFAULT 'text',
                sender_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                attachment_url TEXT,
                attachment_name TEXT,
                attachment_size INTEGER,
                reply_to_id INTEGER REFERENCES "Message"(id) ON DELETE SET NULL,
                receiver_id TEXT REFERENCES "User"(id) ON DELETE CASCADE,
                project_id INTEGER REFERENCES "Project"(id) ON DELETE CASCADE,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_message_sender ON "Message" (sender_id);',
            'CREATE INDEX IF NOT EXISTS idx_message_receiver ON "Message" (receiver_id);',
            'CREATE INDEX IF NOT EXISTS idx_message_project ON "Message" (project_id);',
            'CREATE INDEX IF NOT EXISTS idx_message_type ON "Message" (type);',
        ],
        "columns": ["id", "content", "type", "sender_id", "attachment_url", "attachment_name", "attachment_size", "reply_to_id", "receiver_id", "project_id", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "ProjectFile",
        "create": """
            CREATE TABLE IF NOT EXISTS "ProjectFile" (
                id SERIAL PRIMARY KEY,
                project_id INTEGER NOT NULL REFERENCES "Project"(id) ON DELETE CASCADE,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                name TEXT NOT NULL,
                url TEXT NOT NULL,
                size INTEGER,
                mime_type TEXT,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_projectfile_project ON "ProjectFile" (project_id);',
            'CREATE INDEX IF NOT EXISTS idx_projectfile_user ON "ProjectFile" (user_id);',
        ],
        "columns": ["id", "project_id", "user_id", "name", "url", "size", "mime_type", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "Connection",
        "create": """
            CREATE TABLE IF NOT EXISTS "Connection" (
                id SERIAL PRIMARY KEY,
                sender_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                receiver_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                status TEXT NOT NULL DEFAULT 'pending',
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (sender_id, receiver_id)
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_connection_receiver ON "Connection" (receiver_id);',
            'CREATE INDEX IF NOT EXISTS idx_connection_status ON "Connection" (status);',
        ],
        "columns": ["id", "sender_id", "receiver_id", "status", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "Notification",
        "create": """
            CREATE TABLE IF NOT EXISTS "Notification" (
                id SERIAL PRIMARY KEY,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                type TEXT NOT NULL,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                is_read BOOLEAN NOT NULL DEFAULT FALSE,
                link TEXT,
                created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_notification_user_read ON "Notification" (user_id, is_read);',
            'CREATE INDEX IF NOT EXISTS idx_notification_type ON "Notification" (type);',
        ],
        "columns": ["id", "user_id", "type", "title", "content", "is_read", "link", "created_at"],
        "vector_columns": [],
        "conflict": "id",
    },
    {
        "name": "RoomRead",
        "create": """
            CREATE TABLE IF NOT EXISTS "RoomRead" (
                id SERIAL PRIMARY KEY,
                user_id TEXT NOT NULL REFERENCES "User"(id) ON DELETE CASCADE,
                room_id TEXT NOT NULL,
                last_read_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                UNIQUE (user_id, room_id)
            );
        """,
        "indexes": [
            'CREATE INDEX IF NOT EXISTS idx_roomread_user ON "RoomRead" (user_id);',
        ],
        "columns": ["id", "user_id", "room_id", "last_read_at"],
        "vector_columns": [],
        "conflict": "id",
    },
]


# ── Build INSERT SQL ───────────────────────────────────────────────────────

def build_insert_sql(table_def):
    cols = table_def["columns"]
    vec_cols = table_def["vector_columns"]
    conflict = table_def["conflict"]

    quoted_cols = ", ".join(f'"{c}"' for c in cols)

    placeholders = []
    for i, col in enumerate(cols, start=1):
        ph = f"${i}"
        if col in vec_cols:
            ph += "::vector"
        placeholders.append(ph)
    ph_str = ", ".join(placeholders)

    if conflict:
        on_conflict = f"ON CONFLICT ({conflict}) DO NOTHING"
    else:
        on_conflict = ""

    return f'INSERT INTO "{table_def["name"]}" ({quoted_cols}) VALUES ({ph_str}) {on_conflict}'


# ── Sequence updates (re-sync SERIAL sequences after direct INSERT) ────────

SEQUENCE_TABLES = [
    "OtpCode", "Skill", "Experience", "Project", "ProjectApplication",
    "ProjectMember", "SavedItem", "Task", "Message", "ShowcaseLike",
    "ShowcaseComment", "ProjectFile", "Connection", "Notification", "RoomRead",
]


def seq_name(table):
    # PostgreSQL auto-names SERIAL sequences as "TableName_columnName_seq"
    return f'"{table}_id_seq"'


# ── Main migration ─────────────────────────────────────────────────────────

async def migrate():
    neon_url = os.environ.get("NEON_DATABASE_URL")
    supabase_url = os.environ.get("SUPABASE_URL")
    if not neon_url or not supabase_url:
        print("ERROR: Both NEON_DATABASE_URL and SUPABASE_URL must be set.")
        sys.exit(1)

    source = await asyncpg.connect(dsn=neon_url)
    dest = await asyncpg.connect(dsn=supabase_url)

    try:
        # ── 1. Enable pgvector ──────────────────────────────────────────
        print("Enabling pgvector extension...")
        await dest.execute("CREATE EXTENSION IF NOT EXISTS vector")

        # ── 2. Create tables & indexes ──────────────────────────────────
        print("Creating tables...")
        for t in TABLES:
            await dest.execute(t["create"])
            for idx in t["indexes"]:
                await dest.execute(idx)
            print(f"  Table '{t['name']}' ready.")

        # ── 3. Migrate data ─────────────────────────────────────────────
        print("\nMigrating data...")
        for t in TABLES:
            table = t["name"]
            columns = t["columns"]
            vec_cols = t["vector_columns"]
            conflict = t["conflict"]

            cols_str = ", ".join(f'"{c}"' for c in columns)
            select_sql = f'SELECT {cols_str} FROM "{table}"'

            rows = await source.fetch(select_sql)
            count = len(rows)
            if count == 0:
                print(f"  {table}: 0 rows (skipping)")
                continue

            insert_sql = build_insert_sql(t)

            transformed = [prepare_row(r, vec_cols) for r in rows]
            values_list = [
                [row[c] for c in columns]
                for row in transformed
            ]

            # Insert in batches of 500
            batch_size = 500
            inserted = 0
            for i in range(0, len(values_list), batch_size):
                batch = values_list[i : i + batch_size]
                # Use executemany for efficiency
                await dest.executemany(insert_sql, batch)
                inserted += len(batch)
                print(f"  {table}: {inserted}/{count} rows inserted", end="\r")

            # Update sequences for tables with SERIAL PK
            if table in SEQUENCE_TABLES:
                seq = seq_name(table)
                update_seq = f"SELECT setval('{seq}', COALESCE((SELECT MAX(id) FROM \"{table}\"), 0))"
                try:
                    await dest.execute(update_seq)
                except asyncpg.UndefinedTableError:
                    pass  # sequence might not exist for non-SERIAL PK

            print(f"  {table}: {count} rows inserted     ")

        # ── 4. Summary ──────────────────────────────────────────────────
        print("\nMigration complete!")

    finally:
        await source.close()
        await dest.close()


if __name__ == "__main__":
    asyncio.run(migrate())
