"""
Seed Script: Buat user dummy ke database untuk testing.
Jalankan: python seed.py
"""
import asyncio
from prisma import Prisma
from app.core.security import hash_password


DUMMY_USERS = [
    {
        "nim": "230401010",
        "password": "password123",
        "full_name": "Rudi Sutrisno",
    },
    {
        "nim": "230401011",
        "password": "password123",
        "full_name": "Siti Aminah",
    },
    {
        "nim": "230401012",
        "password": "password123",
        "full_name": "Budi Santoso",
    },
]


async def main():
    db = Prisma()
    await db.connect()

    print("🌱 Mulai seeding database...\n")

    for user_data in DUMMY_USERS:
        # Cek apakah user sudah ada
        existing = await db.user.find_unique(where={"nim": user_data["nim"]})
        if existing:
            print(f"  ⏭️  Skip: {user_data['full_name']} (NIM {user_data['nim']}) — sudah ada.")
            continue

        user = await db.user.create(
            data={
                "nim": user_data["nim"],
                "password": hash_password(user_data["password"]),
                "full_name": user_data["full_name"],
            }
        )
        print(f"  ✅ Created: {user.full_name} (NIM: {user.nim}, ID: {user.id})")

    print("\n🎉 Seeding selesai!")
    print("\n📋 Kredensial Login Dummy:")
    print("=" * 45)
    for u in DUMMY_USERS:
        print(f"   NIM: {u['nim']}  |  Password: {u['password']}")
    print("=" * 45)

    await db.disconnect()


if __name__ == "__main__":
    asyncio.run(main())
