# ZestyBite — Customer Ordering System

A full-stack food ordering platform with a Django REST API backend and a Flutter frontend.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Backend Setup](#backend-setup)
    - [Frontend Setup](#frontend-setup)
- [Running the Project](#running-the-project)
- [Running Tests](#running-tests)
- [API Overview](#api-overview)
- [Updating Order Status (Admin Utility)](#updating-order-status-admin-utility)

---

## Features

|Feature|Description|
|---|---|
|**Authentication**|JWT-based register and login with brute-force lockout (5 failed attempts → 15-minute lockout)|
|**Menu Browsing**|Retrieve active catalogs and available items with search and category filtering|
|**Cart Management**|Add, update, and remove items; price snapshots; cart validation against live menu prices|
|**Order Placement**|Convert cart to order atomically; live DB pricing; idempotency guard against double-clicks|
|**Payment Processing**|Stripe-backed payment sessions; CASH and CARD support; webhook handling; retry logic|
|**Order Tracking**|Real-time status timeline with progress percentage and estimated time|
|**Notifications**|In-app notifications for order events; paginated list; mark as read / mark all as read|

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter Client                        │
│           (Web / iOS / Android / Desktop)                    │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS / REST (JSON)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     Django REST API                          │
│                                                              │
│  ┌─────────────┐  ┌──────────┐  ┌────────┐  ┌──────────┐  │
│  │    auth     │  │   menu   │  │  cart  │  │  order   │  │
│  ├─────────────┤  ├──────────┤  ├────────┤  ├──────────┤  │
│  │  payments   │  │  notif.  │  │        │  │          │  │
│  └─────────────┘  └──────────┘  └────────┘  └──────────┘  │
│                                                              │
│  CustomJWTAuthentication  →  all protected endpoints         │
└────────────────────────┬────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
    SQLite DB      Stripe API     In-Memory Cache
   (database.db)  (payments)     (login lockout)
```

### Django App Breakdown

|App|Responsibility|
|---|---|
|`authentication`|Account registration, login, JWT issuance, brute-force protection|
|`menu`|Menu catalogs, categories, items, search and filtering|
|`cart`|Shopping cart lifecycle; item price snapshots|
|`order`|Order placement, order listing, order tracking, status history|
|`payments`|Stripe payment sessions, webhooks, retry logic|
|`notification`|In-app notification creation, delivery status, read state|

### Key Design Decisions

- **Prices stored in pennies** (integer) throughout the database to avoid floating-point precision issues. Converted to dollars only at serialization time.
- **Snapshot fields** on `order_items` ensure completed orders are historically accurate even if menu prices or names change later.
- **JWT identity** is always read from the token — never from request body parameters — preventing account injection attacks.
- **Atomic transactions** on order placement guarantee all-or-nothing writes; a failed availability check rolls back every DB write in that request.
- **Idempotency guard** on order placement returns the same order if a PENDING/CONFIRMED order was placed within the last 30 seconds (protects against double-clicks and network retries).

---

## Tech Stack

### Backend

|Layer|Technology|
|---|---|
|Language|Python 3|
|Framework|Django 6.0.5|
|REST API|Django REST Framework 3.17.1|
|Authentication|`djangorestframework-simplejwt` 5.5.1|
|Payment Gateway|Stripe Python SDK 12.1.0|
|Database|SQLite (via Django ORM)|
|Cache|Django in-memory cache (`LocMemCache`)|
|CORS|`django-cors-headers` 4.3.0|

### Frontend

|Layer|Technology|
|---|---|
|Language|Dart|
|Framework|Flutter|
|State Management|Cubit (flutter_bloc)|
|HTTP Client|Dio|
|Routing|go_router / auto_route|

---

## Project Structure

```
.
├── src/
│   ├── back/                        # Django backend
│   │   ├── apps/
│   │   │   ├── authentication/      # Auth app
│   │   │   ├── menu/                # Menu app
│   │   │   ├── cart/                # Cart app
│   │   │   ├── order/               # Order app
│   │   │   ├── payments/            # Payments app
│   │   │   └── notification/        # Notifications app
│   │   ├── config/                  # Django settings, URLs, WSGI/ASGI
│   │   ├── database/
│   │   │   └── schema.sql           # Reference SQL schema
│   │   ├── manage.py
│   │   ├── update_status.py         # Admin CLI to advance order status
│   │   └── requirements.txt
│   └── front/                       # Flutter frontend
│       └── lib/
│           ├── Core/                # Network, routing, theme, DI
│           └── features/            # cart, menu, orders, notifications
├── docs/
│   ├── ERD.md
│   ├── UML Class Diagram.md
│   ├── SSD.md
│   ├── Activity_Diagram.md
│   ├── Edge Case Analysis.md
│   ├── Requirement and Use Cases.md
│   └── API contracts (per feature)
```

---

## Getting Started

### Prerequisites

|Tool|Version|
|---|---|
|Python|3.10+|
|pip|latest|
|Flutter SDK|3.x+|
|Dart|bundled with Flutter|

---

### Backend Setup

```bash
# 1. Navigate to the backend directory
cd src/back

# 2. Create and activate a virtual environment
python -m venv .venv
source .venv/bin/activate        # macOS / Linux
# .venv\Scripts\activate         # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Apply database migrations
python manage.py migrate

# 5. (Optional) Seed the database via Django admin or SQL
#    Reference schema is at database/schema.sql

# 6. (Optional) Set Stripe credentials via environment variables
export STRIPE_SECRET_KEY=sk_test_...
export STRIPE_PUBLISHABLE_KEY=pk_test_...
export STRIPE_WEBHOOK_SECRET=whsec_...
```

---

### Frontend Setup

```bash
# 1. Navigate to the frontend directory
cd src/front

# 2. Install Flutter dependencies
flutter pub get
```

---

## Running the Project

### Backend

```bash
cd src/back
source .venv/bin/activate
python manage.py runserver 127.0.0.1:8000
```

The API is now available at `http://127.0.0.1:8000`.

### Frontend

```bash
cd src/front

# Web (Chrome)
flutter run -d chrome

# Web server (accessible on a port)
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

# macOS
flutter run -d macos

# iOS (requires Xcode)
flutter run -d ios

# Android
flutter run -d android
```

Make sure the backend is running before launching the Flutter app.

---

## Running Tests

All test commands must be run from `src/back` with the virtual environment active.

```bash
cd src/back
source .venv/bin/activate

# Check for configuration errors
python manage.py check

# Run all tests
python manage.py test

# Run tests for a specific app
python manage.py test apps.authentication
python manage.py test apps.menu
python manage.py test apps.cart
python manage.py test apps.order
python manage.py test apps.payments
python manage.py test apps.notification
```

---

## API Overview

|Module|Base Path|Auth Required|
|---|---|---|
|Authentication|`/api/auth/`|No (register/login)|
|Menu|`/menu/categories/`|Yes|
|Cart|`/api/cart/`|Yes|
|Orders|`/api/order/`|Yes|
|Payments|`/api/payments/`|Yes|
|Notifications|`/api/notifications/`|Yes|

All protected endpoints require:

```
Authorization: Bearer <JWT_ACCESS_TOKEN>
```

Tokens are obtained from `POST /api/auth/login/` or `POST /api/auth/register/` and are valid for **30 minutes**.

For full request/response shapes see the API contract documents in the `docs/` folder.

---

## Updating Order Status (Admin Utility)

A CLI script is provided to manually advance an order's status during development or testing:

```bash
cd src/back
source .venv/bin/activate

python update_status.py <order_id> <STATUS>
```

Valid statuses: `PENDING`, `CONFIRMED`, `PREPARING`, `READY`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED`, `FAILED`

**Example:**

```bash
python update_status.py 4a9122b7-c2da-4a2e-8261-8bf4d8d2c56d PREPARING
```

This updates the order row and appends a new entry to `order_status_history`, which is reflected immediately in the tracking endpoint.