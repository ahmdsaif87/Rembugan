# Rembugan Mobile App

The mobile application for the Rembugan ("LinkedIn for Students") platform, built using **Flutter** and **GetX** for state management.

## App Features
- Authentication (Login, Register, OTP Verification)
- User Profile & Portfolio (Showcase)
- Project Exploration & AI-based Matchmaking
- Workspace & Task Management (Kanban)
- Chat Feature (Direct Message & Group)
- Competitions Exploration

## Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (to run on emulator/simulator)

## Local Setup

1. Clone the repository and navigate to the frontend directory:
   ```bash
   cd rembugan_frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Setup Environment Variables (if there is an API base URL configuration):
   Ensure the base URL points to the local or staging backend according to your environment (`lib/app/core/utils` or config file).

4. Run the App:
   ```bash
   flutter run
   ```

## Main Directory Structure
This project uses the GetX pattern architecture:
- `lib/app/data/` : Models, providers, API services (Dio).
- `lib/app/modules/` : Pages, controllers, and bindings (View & Logic).
- `lib/app/core/` : Utilities, themes, colors, routing.

## Important Note
Avoid placing heavy logic in the View. Use Controllers (GetX) to manage state and business logic.
