import asyncio
from prisma import Prisma

async def main():
    db = Prisma()
    await db.connect()
    # Check if a task has assignees
    task = await db.task.find_first(include={"assignees": {"include": {"user": True}}})
    if task:
        print(task.title, task.assignees)
    else:
        print("No task")
    await db.disconnect()

asyncio.run(main())
