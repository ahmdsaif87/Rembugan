#!/usr/bin/env python3
"""Re-embed semua user, project, showcase yang belum punya embedding."""
import asyncio, os
os.environ["DATABASE_URL"] = "postgresql://postgres.tgzfnvgzwxtfhvgldvhg:kojirolukaku9@aws-0-ap-southeast-1.pooler.supabase.com:5432/postgres?sslmode=require"

import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "rembugan-backend"))
os.chdir(os.path.join(os.path.dirname(__file__), "..", "rembugan-backend"))

from prisma import Prisma
from app.services.embedding import generate

db = Prisma(autoflush=True)

async def main():
    await db.connect()

    # Re-embed users without embeddings
    users = await db.query_raw('SELECT id FROM "User" WHERE embedding IS NULL')
    for u in users:
        user = await db.user.find_unique(where={"id": u["id"]}, include={"skills": {"include": {"skill": True}}})
        if user:
            from app.services.embedding import text_for_user
            txt = text_for_user(user)
            emb = await generate(txt)
            if emb:
                vec = f'[{",".join(str(x) for x in emb)}]'
                await db.query_raw('UPDATE "User" SET embedding = $1::vector WHERE id = $2', vec, u["id"])
                print(f"  User {u['id'][:8]} embedded")

    # Re-embed projects without embeddings
    projects = await db.query_raw('SELECT id FROM "Project" WHERE embedding IS NULL')
    for p in projects:
        project = await db.project.find_unique(where={"id": p["id"]})
        if project:
            from app.services.embedding import text_for_project
            txt = text_for_project(project.title, project.description, project.required_skills or [])
            emb = await generate(txt)
            if emb:
                vec = f'[{",".join(str(x) for x in emb)}]'
                await db.query_raw('UPDATE "Project" SET embedding = $1::vector WHERE id = $2', vec, p["id"])
                print(f"  Project {p['id']} embedded")

    # Re-embed showcases without embeddings
    showcases = await db.query_raw('SELECT id FROM "Showcase" WHERE embedding IS NULL')
    for s in showcases:
        showcase = await db.showcase.find_unique(where={"id": s["id"]})
        if showcase:
            from app.services.embedding import text_for_showcase
            txt = text_for_showcase(showcase.content, showcase.tags or [])
            emb = await generate(txt)
            if emb:
                vec = f'[{",".join(str(x) for x in emb)}]'
                await db.query_raw('UPDATE "Showcase" SET embedding = $1::vector WHERE id = $2', vec, s["id"])
                print(f"  Showcase {s['id'][:8]} embedded")

    await db.disconnect()

asyncio.run(main())
