<p align="center">
  <h1 align="center">🚀 FlowTech — Agency Management Platform</h1>
  <p align="center">
    A full-stack business management system with an <strong>Admin Dashboard</strong> (Next.js) and a <strong>Salesman Mobile App</strong> (Flutter), connected via a shared PostgreSQL backend.
  </p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Next.js-16-black?logo=next.js" alt="Next.js" />
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/PostgreSQL-Supabase-4169E1?logo=postgresql" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/Drizzle_ORM-latest-C5F74F?logo=drizzle" alt="Drizzle" />
  <img src="https://img.shields.io/badge/Auth-BetterAuth-blueviolet" alt="BetterAuth" />
  <img src="https://img.shields.io/badge/Deployed-Vercel-000?logo=vercel" alt="Vercel" />
</p>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
  - [Admin Dashboard](#-admin-dashboard)
  - [Salesman Mobile App](#-salesman-mobile-app)
- [Database Schema](#-database-schema)
- [API Endpoints](#-api-endpoints)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Dashboard Setup](#1-dashboard-setup)
  - [Mobile App Setup](#2-mobile-app-setup)
- [Environment Variables](#-environment-variables)
- [Building for Production](#-building-for-production)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🌟 Overview

**FlowTech** is an end-to-end agency/distribution management platform designed for small-to-medium FMCG distributors. It digitizes the entire workflow from order placement by field salesmen to approval by admins, stock management, invoicing, and payment tracking.

The system consists of two main applications:

| Application | Technology | Purpose |
|-------------|-----------|---------|
| **Admin Dashboard** | Next.js 16 (App Router) | Web-based admin panel for managing orders, inventory, shops, salesmen, and reports |
| **Salesman Mobile App** | Flutter (Android/iOS) | Field sales app for placing orders, managing shops, generating invoices, and recording payments |

Both applications share a single **PostgreSQL** database hosted on **Supabase** and communicate through a RESTful API layer.

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        CLIENTS                               │
│                                                              │
│   ┌─────────────────┐          ┌──────────────────────┐      │
│   │  Admin Dashboard │          │  Salesman Mobile App  │     │
│   │  (Next.js 16)    │          │  (Flutter + Riverpod) │     │
│   │  Vercel Hosted   │          │  Android APK          │     │
│   └────────┬────────┘          └──────────┬───────────┘      │
│            │                               │                  │
└────────────┼───────────────────────────────┼──────────────────┘
             │ Server Actions &              │ REST API
             │ Server Components             │ /api/mobile/*
             ▼                               ▼
┌──────────────────────────────────────────────────────────────┐
│                     BACKEND (Next.js API)                     │
│                                                              │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│   │ Server       │  │ API Routes   │  │ Middleware    │      │
│   │ Actions      │  │ /api/mobile  │  │ (Auth Guard)  │      │
│   │ (orders.ts)  │  │ /api/delivery│  │ Role-Based    │      │
│   └──────┬───────┘  └──────┬───────┘  └──────────────┘      │
│          │                  │                                 │
│          ▼                  ▼                                 │
│   ┌──────────────────────────────┐                           │
│   │     Drizzle ORM              │                           │
│   │     (Type-safe SQL)          │                           │
│   └──────────────┬───────────────┘                           │
└──────────────────┼───────────────────────────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────────────────────────┐
│                    DATABASE                                   │
│            PostgreSQL (Supabase)                              │
│                                                              │
│   users · shops · products · product_variants                │
│   orders · order_items · payments · stock_ledger             │
│   suppliers · notifications · sessions                       │
└──────────────────────────────────────────────────────────────┘
```

---

## 🛠 Tech Stack

### Admin Dashboard
| Layer | Technology |
|-------|-----------|
| **Framework** | Next.js 16 (App Router, React 19 RC) |
| **Language** | TypeScript |
| **Styling** | Tailwind CSS 3.4 |
| **UI Components** | shadcn/ui (Radix UI primitives) |
| **Charts** | Recharts |
| **ORM** | Drizzle ORM |
| **Authentication** | BetterAuth (email/password) |
| **Database** | PostgreSQL (Supabase) |
| **PDF Generation** | jsPDF + jspdf-autotable |
| **CSV Import** | PapaParse |
| **Forms** | React Hook Form + Zod validation |
| **Hosting** | Vercel |

### Salesman Mobile App
| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **State Management** | Riverpod (StateNotifier) |
| **Routing** | GoRouter |
| **Local Storage** | SharedPreferences |
| **PDF Generation** | dart `pdf` package |
| **Sharing** | `printing` package (native share sheet) |
| **Networking** | `http` package |
| **Icons** | Lucide Icons |
| **Fonts** | Google Fonts |

---

## ✨ Features

### 📊 Admin Dashboard

| Feature | Description |
|---------|------------|
| **Dashboard Overview** | Real-time stats — Total Revenue, Pending Orders, Today's Orders, Pending Payments, Stock Levels |
| **Revenue Chart** | Monthly revenue visualization (Recharts) with dark mode tooltip support |
| **Recent Sales** | Live feed of latest approved/delivered orders (auto-excludes rejected) |
| **Order Management** | View all orders, approve/reject with one click, auto-notify salesmen |
| **Inventory System** | Products with variants (SKU, price, stock), CSV bulk import, stock-in dialogs |
| **Stock Ledger** | Full audit trail of every stock movement (stock-in, orders, adjustments) |
| **Invoice Generation** | PDF invoices with GST breakdown (CGST/SGST), company branding, download support |
| **Supplier Management** | CRUD operations for suppliers, link suppliers to products |
| **Shop Management** | Track shops, outstanding balances, active/inactive status |
| **Salesman Management** | Manage field sales team accounts and assign areas |
| **Payment Tracking** | Monitor paid/unpaid orders, outstanding balances per shop |
| **Dark Mode** | Full dark mode support with smooth theme toggling |
| **Role-Based Access** | Middleware-enforced admin-only access to dashboard |

### 📱 Salesman Mobile App

| Feature | Description |
|---------|------------|
| **Authentication** | Secure login with session management |
| **City Selection** | Multi-city support — salesmen select their operating city |
| **Dashboard** | Personal stats — today's orders, pending payments, quick actions |
| **Order Creation** | Select shop → browse product catalog → add to cart → review & submit |
| **Order Tracking** | View orders across tabs: Draft, Pending, Approved, Rejected |
| **Invoice Preview** | Full on-device invoice preview matching the admin's PDF format |
| **Invoice Sharing** | Generate PDF and share via WhatsApp, email, etc. using native share sheet |
| **Shop Management** | View city-filtered shops, add new shops, view shop details & balances |
| **Bills & Payments** | View outstanding bills, record cash/UPI/bank payments |
| **Payment History** | Full payment timeline per order with status badges |
| **Notifications** | Real-time notifications for order approvals/rejections |
| **Reports** | Daily summary, period reports, shop-wise & product-wise analytics |
| **Route Planning** | Plan daily visit routes, mark shops as visited, place orders during visits |
| **Offline Support** | Local data persistence via SharedPreferences for offline-first usage |
| **Data Sync** | Pull-to-refresh syncs all data (shops, orders, payments) from server |
| **Profile** | View and manage salesman profile |

---

## 🗃 Database Schema

```
┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
│   users      │     │   shops       │     │   suppliers       │
│─────────────│     │──────────────│     │──────────────────│
│ id (PK)      │     │ id (PK)       │     │ id (PK)           │
│ name         │     │ shop_name     │     │ name              │
│ email        │     │ owner_name    │     │ contact_person    │
│ role         │◄────│ city          │     │ email / phone     │
│ phone_number │     │ mobile_number │     │ address           │
│ area         │     │ gst_number    │     └──────────────────┘
└──────┬───────┘     │ address       │              │
       │             │ is_active     │              │
       │             │ outstanding   │     ┌────────▼─────────┐
       │             │ _balance      │     │ supplier_products │
       │             └───────┬───────┘     │──────────────────│
       │                     │             │ supplier_id (FK)  │
       │                     │             │ product_id (FK)   │
       │              ┌──────▼───────┐     └──────────────────┘
       │              │   orders      │
       │              │──────────────│     ┌──────────────────┐
       ├──────────────│ salesman_id   │     │   products        │
       │              │ shop_id (FK)  │     │──────────────────│
       │              │ total_amount  │     │ id (PK)           │
       │              │ paid_amount   │     │ name / category   │
       │              │ status        │     │ base_price        │
       │              │ is_paid       │     └────────┬─────────┘
       │              │ approver_id   │              │
       │              └───────┬───────┘     ┌────────▼─────────┐
       │                      │             │ product_variants  │
       │               ┌──────▼───────┐     │──────────────────│
       │               │ order_items   │     │ sku / price       │
       │               │──────────────│     │ current_stock     │
       │               │ variant_id    │◄────│ variant_name      │
       │               │ quantity      │     └────────┬─────────┘
       │               │ price         │              │
       │               └──────────────┘     ┌────────▼─────────┐
       │                                    │ stock_ledger      │
       │              ┌──────────────┐      │──────────────────│
       ├──────────────│  payments     │      │ change_amount     │
       │              │──────────────│      │ type (IN/OUT/ADJ) │
       │              │ order_id (FK) │      │ reference_id      │
       │              │ shop_id (FK)  │      │ supplier_id (FK)  │
       │              │ amount / mode │      └──────────────────┘
       │              └──────────────┘
       │
       │              ┌──────────────┐
       └──────────────│ notifications │
                      │──────────────│
                      │ salesman_id   │
                      │ type / title  │
                      │ message       │
                      │ is_new        │
                      └──────────────┘
```

---

## 🔌 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|------------|
| `POST` | `/api/auth/[...all]` | BetterAuth handler (login, register, session) |
| `POST` | `/api/mobile/auth/login` | Mobile app authentication |

### Mobile Sync & Data
| Method | Endpoint | Description |
|--------|----------|------------|
| `GET` | `/api/mobile/data/sync?salesmanId=` | Full data sync (shops, products, orders, payments, notifications, stats) |
| `POST` | `/api/mobile/orders/create` | Submit a new order from mobile |
| `POST` | `/api/mobile/payments/create` | Record a payment from mobile |
| `POST` | `/api/mobile/shops/create` | Register a new shop from mobile |
| `POST` | `/api/mobile/shops/update-status` | Update shop active/inactive status |

### Delivery
| Method | Endpoint | Description |
|--------|----------|------------|
| `GET` | `/api/delivery/order` | Get orders ready for delivery |
| `PATCH` | `/api/delivery/order/[id]/status` | Update delivery status |

### Admin (Server Actions)
| Action | File | Description |
|--------|------|------------|
| `createOrder` | `src/actions/orders.ts` | Create order with stock validation |
| `approveOrder` | `src/actions/orders.ts` | Approve order, deduct stock, update shop balance |
| `rejectOrder` | `src/actions/orders.ts` | Reject order and notify salesman |

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+ and npm
- **Flutter** 3.x SDK with Android SDK configured
- **PostgreSQL** database (recommend [Supabase](https://supabase.com) free tier)

### 1. Dashboard Setup

```bash
# Clone the repository
git clone https://github.com/GARJE-01/FlowTech.git
cd FlowTech

# Install dependencies
npm install

# Set up environment variables (see below)
cp .env.example .env

# Push database schema
npx drizzle-kit push

# Run development server
npm run dev
```

The dashboard will be available at `http://localhost:3000`.

### 2. Mobile App Setup

```bash
# Navigate to mobile app directory
cd mobile_app

# Install Flutter dependencies
flutter pub get

# Run on Chrome (for testing)
flutter run -d chrome

# Run on connected Android device
flutter run

# Build release APK
flutter build apk --release
```

The APK will be generated at:
```
mobile_app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔐 Environment Variables

Create a `.env` file in the project root:

```env
# Database (Supabase PostgreSQL)
DATABASE_URL=postgresql://postgres:<password>@<host>:5432/postgres

# BetterAuth
BETTER_AUTH_SECRET=<your-secret-key>
BETTER_AUTH_URL=http://localhost:3000

# Deployment URL (update after deploying to Vercel)
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

> **Mobile App:** Update the API base URL in `mobile_app/lib/src/core/network/api_client.dart` to point to your deployed Vercel URL.

---

## 📦 Building for Production

### Dashboard (Vercel)

```bash
# Build production bundle
npm run build

# Or deploy directly via Vercel CLI
npx vercel --prod
```

The project is configured for automatic deployments on push to the `Dashboard` branch.

### Mobile App (APK)

```bash
cd mobile_app

# Generate launcher icons (if icon changed)
dart run flutter_launcher_icons

# Build release APK
flutter build apk --release
```

---

## 📁 Project Structure

```
FlowTech/
├── src/                          # Next.js Dashboard Source
│   ├── app/
│   │   ├── admin/                # Admin pages
│   │   │   ├── page.tsx          # Dashboard (stats, charts, recent sales)
│   │   │   ├── layout.tsx        # Admin layout with sidebar
│   │   │   ├── orders/           # Order management pages
│   │   │   ├── inventory/        # Product & stock management
│   │   │   ├── shops/            # Shop management
│   │   │   ├── salesmen/         # Salesman management
│   │   │   ├── suppliers/        # Supplier management
│   │   │   └── stock-ledger/     # Stock audit trail
│   │   ├── api/
│   │   │   ├── auth/             # BetterAuth endpoints
│   │   │   ├── mobile/           # Mobile app REST API
│   │   │   └── delivery/         # Delivery management API
│   │   └── login/                # Login page
│   ├── actions/                  # Server actions (order approve/reject)
│   ├── components/               # Reusable UI components (shadcn/ui)
│   ├── db/
│   │   ├── schema.ts             # Drizzle ORM schema definitions
│   │   ├── index.ts              # DB connection
│   │   └── queries.ts            # Reusable database queries
│   └── lib/                      # Utilities (auth, notifications)
├── mobile_app/                   # Flutter Salesman App
│   ├── lib/
│   │   ├── main.dart             # App entry point & provider setup
│   │   └── src/
│   │       ├── core/
│   │       │   ├── network/      # API client & sync service
│   │       │   ├── router/       # GoRouter configuration
│   │       │   ├── storage/      # SharedPreferences service
│   │       │   ├── theme/        # App theme & colors
│   │       │   └── widgets/      # Shared widgets (navbar, placeholders)
│   │       └── features/
│   │           ├── auth/         # Login screen & auth state
│   │           ├── city/         # City selection
│   │           ├── dashboard/    # Salesman home dashboard
│   │           ├── shop/         # Shop list, detail, add shop
│   │           ├── order/        # Order creation (cart, products)
│   │           ├── order_tracking/# Order list & detail (by status)
│   │           ├── invoice/      # Invoice preview & PDF sharing
│   │           ├── payment/      # Payment recording & history
│   │           ├── bills/        # Bills/outstanding view
│   │           ├── notification/ # Push notifications
│   │           ├── reports/      # Business analytics
│   │           ├── route/        # Daily route planning
│   │           └── profile/      # User profile
│   ├── test/                     # Automated test suites
│   └── assets/icon/              # App launcher icon source
├── drizzle/                      # Database migrations
├── middleware.ts                  # Auth & RBAC middleware
├── drizzle.config.ts             # Drizzle Kit configuration
└── package.json                  # Node.js dependencies
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'feat: add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

<p align="center">
  Built with ❤️ by <a href="https://github.com/GARJE-01">GARJE-01</a>
</p>
