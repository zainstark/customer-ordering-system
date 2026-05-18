# ZestyBite — Backend

A Django REST Framework backend for the **ZestyBite Customer Ordering System**, supporting a full food-ordering workflow: authentication, menu browsing, cart management, order placement, payment processing, order tracking, and in-app notifications.

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
- [Apps](#apps)
- [API Overview](#api-overview)
- [Authentication](#authentication)
- [Database](#database)
- [Getting Started](#getting-started)
- [Running Tests](#running-tests)
- [Environment Variables](#environment-variables)
- [Business Rules & Design Decisions](#business-rules--design-decisions)

---

## Tech Stack

| Dependency | Version |
|---|---|
| Python / Django | 6.0.5 |
| Django REST Framework | 3.17.1 |
| djangorestframework-simplejwt | 5.5.1 |
| django-cors-headers | 4.3.0 |
| Stripe SDK | 12.1.0 |
| SQLite | (default, file-based) |

---

## Project Structure

```
src/back/
├── config/                  # Django project config
│   ├── settings.py
│   ├── urls.py              # Root URL routing
│   ├── asgi.py
│   └── wsgi.py
├── apps/
│   ├── authentication/      # JWT auth, account registration/login
│   ├── menu/                # Menu catalogs, categories, and items
│   ├── cart/                # Shopping cart and cart items
│   ├── order/               # Order placement, listing, and tracking
│   ├── payments/            # Stripe payment sessions, webhooks
│   └── notification/        # In-app notification messages
├── database/
│   ├── schema.sql           # SQLite schema (source of truth)
│   └── database.db          # SQLite database file (gitignored)
├── update_status.py         # CLI utility to manually update order status
├── manage.py
└── requirements.txt
```

Each app follows the standard Django pattern:

```
apps/<app>/
├── models.py
├── views.py
├── serializers.py
├── services.py      # All business logic lives here — views are thin
├── urls.py
├── tests.py
└── apps.py
```

---

## Architecture Overview

The backend follows a **service layer pattern**: views validate HTTP input, delegate all business logic to a dedicated `services.py` module, and serialize the result back to JSON. Views contain no business logic.

```
HTTP Request
    │
    ▼
View (DRF)          ← validates request shape, extracts account_id from JWT
    │
    ▼
Service Layer       ← all business rules, DB writes, validations
    │
    ▼
Django ORM / Models
    │
    ▼
SQLite Database
```

---

## Apps

### `authentication`
Handles account registration, login, and JWT issuance. Uses a **custom JWT authentication class** (`CustomJWTAuthentication`) that reads the `account_id` claim from the token and looks up the corresponding `Accounts` record on every request.

- Brute-force lockout: accounts are locked for 15 minutes after 5 consecutive failed login attempts within a 10-minute window (tracked in Django's local memory cache).
- Tokens have a **30-minute lifetime**. No refresh token is issued by default.

### `menu`
Exposes active menu catalogs with their available items. Supports search (by item name/description) and category filtering via query parameters. Prices are stored in pennies and returned as floating-point dollars.

### `cart`
Manages a single active cart per account. Supports adding, updating, and removing items, as well as validation (availability and price consistency). Prices in the cart are stored as snapshots at the time of addition.

### `order`
Converts a cart into a confirmed order atomically. Key behaviors:
- Prices are **always recalculated from live DB values**, never from cart snapshots (prevents price tampering).
- A 30-second idempotency guard prevents duplicate orders from double-clicks or network retries.
- On successful placement, the cart is cleared and an initial `OrderStatusHistory` record is created.
- Supports order tracking with a status timeline and estimated delivery time.

### `payments`
Integrates with **Stripe** for card payments and supports cash payments. Exposes endpoints to create a payment session, check payment status, retry a failed payment, and receive Stripe webhook events. The `PaymentGatewayAdapter` interface allows the real Stripe adapter to be swapped out in tests.

### `notification`
Creates and manages in-app notifications (`delivery_channel = IN_APP`). Notifications are created automatically when orders are placed or their status changes. Supports paginated listing, unread count, mark-as-read, and mark-all-as-read.

---

## API Overview

All endpoints use `Content-Type: application/json`. Protected endpoints require:

```
Authorization: Bearer <access_token>
```

| Prefix | App | Description |
|---|---|---|
| `POST /api/auth/register/` | authentication | Create a new account |
| `POST /api/auth/login/` | authentication | Log in and receive a JWT |
| `POST /api/auth/logout/` | authentication | Client-side session clear |
| `GET /menu/categories/` | menu | List active catalogs with items |
| `GET /api/cart/` | cart | Get the authenticated user's cart |
| `POST /api/cart/items/` | cart | Add an item to the cart |
| `PATCH /api/cart/items/<id>/` | cart | Update cart item quantity |
| `DELETE /api/cart/items/<id>/delete/` | cart | Remove a cart item |
| `POST /api/cart/validate/` | cart | Validate cart items (availability, price) |
| `DELETE /api/cart/clear/` | cart | Clear the entire cart |
| `GET /api/order/` | order | List the account's orders (newest first) |
| `POST /api/order/place/` | order | Place a new order from the current cart |
| `GET /api/order/<id>/tracking/` | order | Get order status and history |
| `POST /api/payments/create-session/` | payments | Create a Stripe or cash payment session |
| `GET /api/payments/<id>/status/` | payments | Get current payment status |
| `POST /api/payments/<id>/retry/` | payments | Retry a failed payment |
| `POST /api/payments/webhook/` | payments | Stripe webhook endpoint |
| `GET /api/notifications/list` | notification | Paginated list of in-app notifications |
| `GET /api/notifications/unread-count` | notification | Count of unread notifications |
| `PATCH /api/notifications/<id>/read` | notification | Mark a single notification as read |
| `PATCH /api/notifications/mark-all-read` | notification | Mark all notifications as read |

Full request/response contracts are documented in the `Docs/` folder:
- `API_Contract_Authentication.md`
- `API_Contract_Menu.md`
- `cart_API_CONTRACT.md`
- `order_API_CONTRACT.md`
- `checkout_API_CONTRACT.md`
- `API_CONTRACT_NOTIFICATIONS.md`

---

## Authentication

The backend uses stateless **JWT bearer tokens** issued by `rest_framework_simplejwt`. The custom authenticator (`CustomJWTAuthentication`) decodes the token and validates:

1. Header starts with `Bearer `.
2. Signature is valid and token has not expired.
3. The `account_id` claim maps to an existing `Accounts` record.
4. The account is active (`active = True`).

The token payload carries: `account_id`, `email`, `role`, `display_name`, `exp`.

**The `account_id` is always sourced from the token** — never from query parameters or the request body. This prevents cross-account data access (EC-UC7-01, EC-UC4-04).

---

## Database

SQLite is used as the default database. The full schema is defined in `database/schema.sql`.

### Core Tables

| Table | Purpose |
|---|---|
| `accounts` | Customer accounts |
| `menu_catalogs` | Groupings of menu items |
| `categories` | Food categories (Starters, Mains, etc.) |
| `menu_items` | Individual food products with prices in pennies |
| `carts` | One active cart per account |
| `cart_items` | Items in a cart with price snapshots |
| `orders` | Finalized orders |
| `order_items` | Immutable snapshots of items at order time |
| `order_status_history` | Timeline of order status changes |
| `payments` | Payment attempts and their state |
| `transactions` | Gateway responses (authorization codes, etc.) |
| `notification_messages` | Multi-channel notifications (IN_APP, EMAIL, SMS, WHATSAPP) |

### Pricing Convention

All monetary values are stored as **integers in pennies** to avoid floating-point precision issues. All API responses return prices as **float dollars** (divided by 100).

---

## Getting Started

### Prerequisites

- Python 3.11+
- A virtual environment (`.venv`)

### Setup

```bash
# 1. Navigate to the backend directory
cd src/back

# 2. Activate the virtual environment
source .venv/bin/activate          # Linux/macOS
# .venv\Scripts\activate           # Windows

# 3. Install dependencies
pip install -r requirements.txt

# 4. Apply migrations
python manage.py migrate

# 5. Start the development server
python manage.py runserver 127.0.0.1:8000
```

The API will be available at `http://127.0.0.1:8000`.

### Creating an Account (via API)

```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"display_name": "Alice", "email": "alice@example.com", "password": "password123"}'
```

### Manually Updating an Order Status

```bash
python update_status.py <order_id> <STATUS>
# Valid statuses: PENDING, CONFIRMED, PREPARING, READY, OUT_FOR_DELIVERY, DELIVERED, CANCELLED, FAILED
```

---

## Running Tests

```bash
cd src/back
source .venv/bin/activate

# Run all tests
python manage.py test

# Run tests for a specific app
python manage.py test apps.authentication
python manage.py test apps.menu
python manage.py test apps.cart
python manage.py test apps.order
python manage.py test apps.payments
python manage.py test apps.notification

# Check for configuration errors
python manage.py check
```

---

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `STRIPE_SECRET_KEY` | For card payments | Stripe secret API key |
| `STRIPE_PUBLISHABLE_KEY` | Optional | Stripe publishable key |
| `STRIPE_WEBHOOK_SECRET` | For webhooks | Stripe webhook signing secret |
| `DJANGO_SETTINGS_MODULE` | Auto-set | Defaults to `config.settings` |

Set these in your shell or a `.env` file before running the server:

```bash
export STRIPE_SECRET_KEY=sk_test_...
export STRIPE_WEBHOOK_SECRET=whsec_...
```

---

## Business Rules & Design Decisions

| Rule | Detail |
|---|---|
| One cart per account | `carts.account_id` is `UNIQUE`; `get_or_create` is used |
| Live pricing at order time | Order totals are computed from `menu_items.price_penny`, never from `cart_items.unit_price_snapshot` |
| Price snapshots in order items | `order_items` stores item name, description, and price at the moment of placement so historical orders remain accurate |
| Idempotent order placement | A `PENDING` or `CONFIRMED` order within the last 30 seconds is returned instead of creating a duplicate |
| Atomic order creation | All DB writes for a placement (order, order items, cart clear, history, notification) run inside a single `transaction.atomic()` block; any failure rolls everything back |
| Authorization over enumeration | Cart item and order endpoints return `404 Not Found` instead of `403 Forbidden` for cross-account access to prevent resource enumeration |
| IN_APP notifications only | The notification endpoints filter exclusively on `delivery_channel = 'IN_APP'`; other channels (EMAIL, SMS, WHATSAPP) exist in the DB schema but are not exposed to the frontend |
| Brute-force protection | Accounts lock for 15 minutes after 5 failed login attempts within 10 minutes |
