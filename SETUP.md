# Panduan Setup Rembugan — Lokal

Panduan untuk menjalankan project Rembugan di laptop teman-teman (Windows & Linux).

---

## 📦 1. Install Docker

Docker digunakan untuk menjalankan Backend, Database Redis, dan Dashboard Admin.

### Windows

1. Download **Docker Desktop** dari https://docs.docker.com/desktop/setup/install/windows-install/
2. Jalankan installer, ikuti petunjuk (restart PC jika diminta)
3. Buka **Docker Desktop** dan tunggu sampai muncul tulisan "Engine running"

> ⚠️ **WSL2**: Saat install, pastikan centang "Use WSL 2 instead of Hyper-V". Kalau belum punya WSL2, Docker akan minta install — ikuti saja.

### Linux (Ubuntu/Debian)

```bash
# Hapus paket docker lama jika ada
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install ca-certificates curl

# Tambah GPG key Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Tambah repository Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-v2

# Biar bisa jalan tanpa sudo
sudo usermod -aG docker $USER
# ⚠️ Logout dulu lalu login lagi (atau restart PC)
```

Cek instalasi:

```bash
docker --version
docker compose version
```

---

## 2. Clone Repository

```bash
git clone <url-repo>
cd rembugan
```

---

## 3. Setup File Environment

```bash
# Backend
cp rembugan-backend/.env.example rembugan-backend/.env

# Dashboard
cp rembugan-dashboard/.env.example rembugan-dashboard/.env.local
```

---

## 4. Jalankan Semua Service

```bash
docker compose up
```

Tunggu beberapa saat (pertama kali ~2-3 menit karena download dependencies & model AI embedding ~67MB).

**Akses:**

| Service | URL |
|---------|-----|
| Backend API | http://localhost:8000 |
| Dashboard Admin | http://localhost:3000 |
| Docs API (Swagger) | http://localhost:8000/docs |

### Login Dashboard

| Email | Password |
|-------|----------|
| `admin@rembugan.com` | (lihat di pengelola tim) |

---

## 5. Flutter Mobile App (Optional)

Kalau mau jalanin aplikasi Flutter juga:

### Prasyarat

- Install **Flutter SDK** (https://docs.flutter.dev/get-started/install)
- Android Studio atau VS Code

### Setup

```bash
cd rembugan_frontend
flutter pub get
flutter run
```

### API URL

- **Android Emulator:** Otomatis pakai `10.0.2.2:8000`
- **Linux Desktop / Web:** Otomatis pakai `localhost:8000`
- **HP Real:** Butuh IP komputer:

```bash
# Cek IP komputer (Linux/Mac)
hostname -I
# Windows
ipconfig
```

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.xx:8000
```

---

## 6. Berhenti

```bash
# Matikan semua container
docker compose down

# Matikan + hapus volume data (redis & model cache)
docker compose down --volumes
```

---

## Troubleshooting

### Database `Can't reach database server`

Neon free tier "sleep" setelah idle. Coba:

```bash
# Bangunin database
docker compose exec backend prisma db push
```

Atau buka console Neon → klik **Start**.

### Port sudah dipakai

```bash
# Cek port
sudo lsof -i :8000
sudo lsof -i :3000
sudo lsof -i :6379

# Kill proses yang pakai port tersebut
kill <PID>
```

### Permission denied Docker

```bash
# Linux: Tambah user ke group docker
sudo usermod -aG docker $USER
# LOGOUT lalu login lagi
```

### Flutter error `type 'String' is not a subtype of type 'int'`

Biasanya karena response API error — cek backend log:

```bash
docker compose logs backend --tail 20
```

---

## Command Cheatsheet

```bash
# Lihat log service tertentu
docker compose logs backend -f    # Backend
docker compose logs dashboard -f  # Dashboard
docker compose logs redis -f      # Redis

# Masuk ke container backend
docker compose exec backend bash

# Jalankan ulang service tertentu
docker compose restart backend

# Rebuild image (setelah ada perubahan)
docker compose build dashboard
```
