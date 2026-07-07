# Rembugan Mobile App

Aplikasi mobile Flutter untuk platform Rembugan.

## Tech Stack

- **Framework:** Flutter + GetX
- **HTTP:** Dio
- **Storage:** flutter_secure_storage
- **WebSocket:** web_socket_channel
- **QR:** mobile_scanner, qr_flutter
- **File:** file_picker, image_picker

## Setup

```bash
cd rembugan_frontend
flutter pub get
flutter run
```

API URL bisa dikustomisasi saat build:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.17:8000
```

Untuk Android emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Struktur (GetX Pattern)

```
lib/
├── app/
│   ├── core/
│   │   ├── config/        # API config, env
│   │   ├── models/        # Data models
│   │   ├── services/      # API client, Auth, Profile, Chat, Theme
│   │   ├── theme/         # Colors, fonts, spacing
│   │   └── widgets/       # Shared widgets
│   ├── modules/           # Feature modules
│   │   ├── home/          # Beranda, feed
│   │   ├── chat/          # Chat list
│   │   ├── room_chat/     # Chat room
│   │   ├── explore/       # Explore proyek
│   │   ├── team/          # Workspace
│   │   ├── profile/       # Profile
│   │   ├── social/        # Posts, comments, search
│   │   └── notification/  # Notifications
│   └── routes/            # Route definitions
└── main.dart
```
