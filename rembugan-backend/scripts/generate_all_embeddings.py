"""One-time script to regenerate embeddings for all users, projects, and showcases."""
import asyncio
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.services.embedding import reembed_user, reembed_project, reembed_showcase
from app.core.database_sql import async_session_factory
from app.models.user import User
from app.models.collaboration import Project
from app.models.social import Showcase
from sqlalchemy import select


async def main():
    async with async_session_factory() as session:
        # Users
        result = await session.execute(select(User.id))
        user_ids = [r[0] for r in result]
        print(f"Re-embedding {len(user_ids)} users...")
        for i, uid in enumerate(user_ids, 1):
            await reembed_user(uid)
            if i % 10 == 0:
                print(f"  users: {i}/{len(user_ids)}")

        # Projects
        result = await session.execute(select(Project.id))
        project_ids = [r[0] for r in result]
        print(f"\nRe-embedding {len(project_ids)} projects...")
        for i, pid in enumerate(project_ids, 1):
            await reembed_project(pid)
            if i % 10 == 0:
                print(f"  projects: {i}/{len(project_ids)}")

        # Showcases
        result = await session.execute(select(Showcase.id))
        showcase_ids = [r[0] for r in result]
        print(f"\nRe-embedding {len(showcase_ids)} showcases...")
        for i, sid in enumerate(showcase_ids, 1):
            await reembed_showcase(sid)
            if i % 10 == 0:
                print(f"  showcases: {i}/{len(showcase_ids)}")

    print("\nDone!")


if __name__ == "__main__":
    asyncio.run(main())
