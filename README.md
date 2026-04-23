# FlowTech — Distribution & Sales Management System

> ✅ **Verification:** This README was updated on **April 23, 2026** to confirm repo identity.

FlowTech is a full-stack distribution and sales management platform with an **Admin Dashboard** (Next.js) and a **Mobile App** (Flutter) for salesmen and delivery personnel.

## Tech Stack

| Component | Technology |
|---|---|
| Admin Dashboard | Next.js 16, React, TypeScript |
| Styling | TailwindCSS, shadcn/ui |
| Database | PostgreSQL (via Drizzle ORM) |
| Auth | Better-Auth |
| Mobile App | Flutter / Dart |
| Deployment | Vercel (Dashboard) |

## Features

### Admin Dashboard
- 📊 Dashboard with sales overview and charts
- 📦 Inventory management (products, variants, stock ledger)
- 🛒 Order management (create, approve, track, deliver)
- 🏪 Shop management
- 👥 Salesman management
- 🏭 Supplier management
- 💰 Payment tracking
- 📄 CSV import for products and suppliers

### Mobile App
- 🔐 Authentication (login/signup)
- 🏙️ City-based shop filtering
- 📋 Order creation and tracking
- 🧾 Invoice generation
- 💵 Payment collection
- 📊 Reports and analytics
- 🔔 Notifications
- 👤 Profile management

## Getting Started

### Dashboard

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the dashboard.

### Mobile App

```bash
cd mobile_app
flutter pub get
flutter run
```

## Project Structure

```
FlowTech/
├── src/                  # Next.js Dashboard
│   ├── app/              # App routes (admin, api, login)
│   ├── components/       # UI components
│   ├── db/               # Database schema & queries
│   ├── actions/          # Server actions
│   ├── hooks/            # Custom React hooks
│   └── lib/              # Utilities
├── mobile_app/           # Flutter Mobile App
│   └── lib/src/
│       ├── core/         # Router, widgets, services
│       └── features/     # Feature modules
├── drizzle/              # Database migrations
└── scripts/              # Utility scripts
```
