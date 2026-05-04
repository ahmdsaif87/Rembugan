import asyncio
import httpx
import uuid

BASE_URL = "http://127.0.0.1:8002"

async def run_tests():
    async with httpx.AsyncClient() as client:
        print("=== MENGUJI API REMBUGAN ===")
        
        # 1. Register & Login
        nim_a = f"NIM_{uuid.uuid4().hex[:6]}"
        nim_b = f"NIM_{uuid.uuid4().hex[:6]}"
        
        print(f"\n1. Register User A ({nim_a})")
        res = await client.post(f"{BASE_URL}/auth/register", json={"nim": nim_a, "password": "password", "full_name": "Ahmad Test"})
        print("Status:", res.status_code, res.json())
        token_a = res.json()["data"]["access_token"]
        user_a_id = res.json()["data"]["user_id"]
        headers_a = {"Authorization": f"Bearer {token_a}"}

        print(f"\n2. Register User B ({nim_b})")
        res = await client.post(f"{BASE_URL}/auth/register", json={"nim": nim_b, "password": "password", "full_name": "Budi Test"})
        print("Status:", res.status_code, res.json())
        token_b = res.json()["data"]["access_token"]
        user_b_id = res.json()["data"]["user_id"]
        headers_b = {"Authorization": f"Bearer {token_b}"}

        # 2. Competitions API
        print("\n3. Get Lomba (All)")
        res = await client.get(f"{BASE_URL}/competitions/all")
        print("Status:", res.status_code, "Data Length:", len(res.json().get("data", [])))

        # 3. Showcase API
        print("\n4. Buat Showcase (User A)")
        res = await client.post(f"{BASE_URL}/showcase/create", json={"isi_postingan": "Proyek pertamaku!", "tags": ["react"]}, headers=headers_a)
        print("Status:", res.status_code, res.json())
        showcase_id = res.json()["data"]["id"]

        print("\n5. Like Showcase (User B)")
        res = await client.post(f"{BASE_URL}/showcase/{showcase_id}/like", headers=headers_b)
        print("Status:", res.status_code, res.json())

        print("\n6. Comment Showcase (User B)")
        res = await client.post(f"{BASE_URL}/showcase/{showcase_id}/comment", json={"content": "Keren banget!"}, headers=headers_b)
        print("Status:", res.status_code, res.json())

        # 4. Project
        print("\n7. Buat Proyek (User A)")
        res = await client.post(f"{BASE_URL}/projects/create", json={"title": "Membangun Aplikasi", "description": "Dicari programmer yang berpengalaman untuk aplikasi ini.", "required_skills": ["python", "react"]}, headers=headers_a)
        print("Status:", res.status_code, res.json())
        project_id = res.json()["data"]["id"]

        print("\n8. Akhiri Kolaborasi (User A)")
        res = await client.post(f"{BASE_URL}/workspace/{project_id}/end", headers=headers_a)
        print("Status:", res.status_code, res.json())

        # 5. Connections
        print("\n9. Kirim Permintaan Teman (User B -> User A)")
        res = await client.post(f"{BASE_URL}/connections/request/{user_a_id}", headers=headers_b)
        print("Status:", res.status_code, res.json())

        print("\n10. Terima Permintaan Teman (User A)")
        # Cek database id untuk connection sebenarnya rumit jika tidak tahu ID, kita skip accept. Atau test notifikasinya saja.

        # 6. Notifications
        print("\n11. Ambil Notifikasi (User A)")
        res = await client.get(f"{BASE_URL}/notifications/", headers=headers_a)
        print("Status:", res.status_code, res.json())
        
        # 7. FYP
        print("\n12. Ambil FYP (User A)")
        res = await client.get(f"{BASE_URL}/fyp/", headers=headers_a)
        print("Status:", res.status_code)
        fyp_data = res.json()
        print(f"Showcases: {len(fyp_data['data']['showcases'])}, Projects: {len(fyp_data['data']['projects'])}, Competitions: {len(fyp_data['data']['competitions'])}")

        # 8. Profile
        print("\n13. Ambil Profile Sendiri (User A)")
        res = await client.get(f"{BASE_URL}/profile/me", headers=headers_a)
        print("Status:", res.status_code, res.json()["data"]["full_name"])

if __name__ == "__main__":
    asyncio.run(run_tests())
