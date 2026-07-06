# Rembugan Dashboard

An interactive admin dashboard to monitor and manage the Rembugan platform. Built with **Next.js (App Router)**, **TypeScript**, and components from **Shadcn UI**.

## Key Features
- Realtime platform statistics and metrics.
- User Management
- Project and Application Management
- Showcase (Portfolio) Management
- Light/Dark mode display with persistence.

## Prerequisites
- Node.js (LTS version recommended)
- npm or yarn

## Local Setup

1. Navigate to the dashboard directory and install dependencies:
   ```bash
   cd rembugan-dashboard
   npm install
   ```

2. Setup Environment Variables:
   Create a `.env.local` file in the root dashboard folder and enter the following credentials:
   ```env
   NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
   NEXT_PUBLIC_ADMIN_USERNAME=admin
   NEXT_PUBLIC_ADMIN_PASSWORD=admin123
   ```
   *(Adjust `NEXT_PUBLIC_API_BASE_URL` if the backend is running on a different port or host).*

3. Run the Development Server:
   ```bash
   npm run dev
   ```

Access the dashboard via your browser at: `http://localhost:3000`. 
If you haven't logged in, you will be redirected to the `/login` page. Use the admin username and password configured in your env file.
