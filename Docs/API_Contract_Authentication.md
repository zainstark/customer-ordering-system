# API Contracts

## Overview

This document covers all API contracts for the **ZestyBite** backend. It includes the Authentication and Notifications features.

- **Base URL:** `http://127.0.0.1:8000`
- **Format:** All request and response bodies are JSON
- **Auth:** All protected endpoints require `Authorization: Bearer <access_token>`
- **Timestamps:** ISO 8601 UTC — e.g. `2026-05-16T14:32:00Z`

---

## Authentication

### Token format

The backend issues signed JWTs via `rest_framework_simplejwt`. Tokens have a **60-minute lifetime**. No refresh token is issued on login or register — clients must re-login on expiry.

**Decoded token payload:**
```json
{
  "account_id":   "string (UUID)",
  "email":        "string",
  "role":         "string",
  "display_name": "string",
  "exp":          1234567890
}
```

**Header (all protected routes):**
```
Authorization: Bearer <access_token>
```

**Server validation steps (`CustomJWTAuthentication`):**
1. Check header starts with `Bearer `
2. Decode and verify JWT signature
3. Look up `Accounts` by `account_id` claim
4. Reject with `401` if `account.active == False`

---

### POST /api/auth/register/

Create a new customer account.

**Auth:** Public

**Request body:**
```json
{
  "display_name": "string (required)",
  "email":        "string (required, unique)",
  "password":     "string (required, min 8 chars)",
  "phone_number": "string (optional)"
}
```

**Response — 201 Created:**
```json
{
  "access": "string (JWT)"
}
```

> The response body also carries `account_id`, `display_name`, `email`, and `role` as top-level fields alongside `access`, which the Flutter client reads via `AccountModel.fromTokenPayload(res.data)`.

**Errors:**

| Status | Condition |
|--------|-----------|
| 400 | Validation failed (missing fields, password too short) |
| 400 | Email already in use |

---

### POST /api/auth/login/

Authenticate an existing account and receive an access token.

**Auth:** Public

**Request body:**
```json
{
  "email":    "string (required)",
  "password": "string (required)"
}
```

**Response — 200 OK:**
```json
{
  "access": "string (JWT)"
}
```

**Errors:**

| Status | Condition |
|--------|-----------|
| 400 | Validation failed |
| 401 | Invalid credentials (wrong email or password) |
| 401 | Account is disabled |

---

### POST /api/auth/logout/

End the session. The server is stateless — no token blacklisting occurs. The client clears stored tokens locally.

**Auth:** Required

**Request body:** none

**Response — 205 Reset Content:** no body

**Errors:**

| Status | Condition |
|--------|-----------|
| 401 | Missing or invalid token |

> Errors on this call are intentionally swallowed by the Flutter client.

---

### POST /api/auth/token/refresh/

Refresh an expired access token using a refresh token.

**Auth:** Public

**Request body:**
```json
{
  "refresh": "string (refresh token)"
}
```

**Response — 200 OK:**
```json
{
  "access": "string (new JWT)"
}
```

**Errors:**

| Status | Condition |
|--------|-----------|
| 401 | Refresh token invalid or expired |

> ⚠️ **Known issue:** `get_tokens()` currently only returns an `access` key — no `refresh` token is ever issued. The Flutter client stores an empty refresh token after login/register, causing `tryRestoreSession()` and the Dio token-refresh interceptor to always fail. Fix by either issuing a refresh token from the backend, or removing the refresh flow from the client entirely.

---

## Notifications

### Overview

Notifications are stored in the `notification_messages` table and support multiple delivery channels (`EMAIL`, `SMS`, `IN_APP`, `WHATSAPP`). All endpoints below filter exclusively on `delivery_channel = 'IN_APP'` and scope results to the authenticated user's `account_id`.

**Base path:** `/api/notifications/`

**Unread definition:** `delivery_status = 'PENDING'`

**Read definition:** `delivery_status = 'DELIVERED'`

**Sort order:** `created_at DESC` (newest first)

---

### GET /api/notifications/list

Fetch a paginated list of IN_APP notifications for the authenticated user.

**Auth:** Required

**Query parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | int | Yes | — | Page number, starting from 1 |
| `limit` | int | No | 10 | Items per page (max 100) |

**Request example:**
```
GET /api/notifications/list?page=1&limit=10
Authorization: Bearer <token>
```

**Response — 200 OK:**
```json
{
  "notifications": [
    {
      "message_id":       "msg_001",
      "subject":          "Order Delivered",
      "body":             "Your burger from Big Bun Grill has been delivered. Enjoy your meal!",
      "delivery_channel": "IN_APP",
      "delivery_status":  "PENDING",
      "created_at":       "2026-05-16T14:32:00Z",
      "sent_at":          "2026-05-16T14:32:00Z",
      "order_id":         "order_123"
    },
    {
      "message_id":       "msg_002",
      "subject":          "Special Discount Available",
      "body":             "Get 20% off on your next Sushi order. Valid for today only!",
      "delivery_channel": "IN_APP",
      "delivery_status":  "PENDING",
      "created_at":       "2026-05-16T13:15:00Z",
      "sent_at":          "2026-05-16T13:15:00Z",
      "order_id":         null
    }
  ],
  "pagination": {
    "page":        1,
    "limit":       10,
    "total":       42,
    "totalPages":  5,
    "hasNextPage": true
  }
}
```

**Response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `notifications[].message_id` | string | Unique notification identifier (DB primary key) |
| `notifications[].subject` | string | Notification title (max 255 chars) |
| `notifications[].body` | string | Notification message body (max 1000 chars) |
| `notifications[].delivery_channel` | string | Always `"IN_APP"` |
| `notifications[].delivery_status` | enum | `PENDING`, `SENT`, `DELIVERED`, or `FAILED` |
| `notifications[].created_at` | string | ISO 8601 UTC datetime |
| `notifications[].sent_at` | string \| null | ISO 8601 UTC datetime, nullable |
| `notifications[].order_id` | string \| null | Related order ID if applicable |
| `pagination.page` | int | Current page |
| `pagination.limit` | int | Items per page |
| `pagination.total` | int | Total notifications across all pages |
| `pagination.totalPages` | int | Total number of pages |
| `pagination.hasNextPage` | boolean | Whether more pages exist |

**Errors:**

| Status | Condition |
|--------|-----------|
| 400 | Invalid query parameters |
| 401 | Missing or invalid token |
| 500 | Failed to fetch notifications |

---

### GET /api/notifications/unread-count

Get the count of unread (`PENDING`) IN_APP notifications for the authenticated user.

**Auth:** Required

**Request example:**
```
GET /api/notifications/unread-count
Authorization: Bearer <token>
```

**Response — 200 OK:**
```json
{
  "unreadCount": 3
}
```

**Response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `unreadCount` | int | Number of notifications with `delivery_status = PENDING` |

**Errors:**

| Status | Condition |
|--------|-----------|
| 401 | Missing or invalid token |
| 500 | Failed to fetch unread count |

---

### PATCH /api/notifications/{message_id}/read

Mark a single IN_APP notification as read (`PENDING` → `DELIVERED`). Operation is idempotent — marking an already-delivered notification is a no-op.

**Auth:** Required

**Path parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `message_id` | string | Notification identifier |

**Request example:**
```
PATCH /api/notifications/msg_001/read
Authorization: Bearer <token>
```

**Request body:** none

**Response — 200 OK:**
```json
{
  "message_id":       "msg_001",
  "subject":          "Order Delivered",
  "body":             "Your burger from Big Bun Grill has been delivered. Enjoy your meal!",
  "delivery_channel": "IN_APP",
  "delivery_status":  "DELIVERED",
  "created_at":       "2026-05-16T14:32:00Z",
  "sent_at":          "2026-05-16T14:32:00Z",
  "order_id":         "order_123"
}
```

Returns the updated notification object.

**Errors:**

| Status | Condition |
|--------|-----------|
| 401 | Missing or invalid token |
| 404 | Notification not found or does not belong to user |
| 500 | Failed to mark notification as read |

---

### PATCH /api/notifications/mark-all-read

Mark all IN_APP notifications for the authenticated user as read (`PENDING` → `DELIVERED`).

**Auth:** Required

**Request example:**
```
PATCH /api/notifications/mark-all-read
Authorization: Bearer <token>
```

**Request body:** none

**Response — 200 OK:**
```json
{
  "success":     true,
  "message":     "All notifications marked as read",
  "markedCount": 5
}
```

**Response fields:**

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Whether the operation succeeded |
| `message` | string | Confirmation message |
| `markedCount` | int | Number of notifications updated |

**Errors:**

| Status | Condition |
|--------|-----------|
| 401 | Missing or invalid token |
| 500 | Failed to mark all notifications as read |

---

## Data models

### Notification object

```typescript
interface Notification {
  message_id:       string;                                        // UUID, primary key
  subject:          string;                                        // Max 255 chars
  body:             string;                                        // Max 1000 chars
  delivery_channel: "IN_APP";
  delivery_status:  "PENDING" | "SENT" | "DELIVERED" | "FAILED";
  created_at:       string;                                        // ISO 8601 UTC
  sent_at?:         string | null;                                 // ISO 8601 UTC, nullable
  order_id?:        string | null;                                 // FK to orders, optional
}
```

### Delivery status values

| Value | Meaning |
|-------|---------|
| `PENDING` | Unread — not yet seen by the user |
| `SENT` | Dispatched but delivery not confirmed |
| `DELIVERED` | Read by the user |
| `FAILED` | Delivery failed |

### AccountEntity (frontend)

```typescript
interface AccountEntity {
  accountId:   string;
  displayName: string;
  email:       string;
  role:        string;
}
```

---

## HTTP status codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created |
| 205 | Reset Content (logout) |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

---

## Database schema reference

```sql
CREATE TABLE accounts (
    account_id    TEXT PRIMARY KEY,
    display_name  TEXT NOT NULL,
    email         TEXT UNIQUE NOT NULL,
    role          TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    phone_number  TEXT,
    active        BOOLEAN NOT NULL,
    created_at    DATETIME NOT NULL,
    updated_at    DATETIME NOT NULL
);

CREATE TABLE notification_messages (
    message_id        TEXT PRIMARY KEY,
    account_id        TEXT NOT NULL,
    order_id          TEXT,
    subject           TEXT,
    body              TEXT,
    delivery_channel  TEXT NOT NULL CHECK(delivery_channel IN ('EMAIL', 'SMS', 'IN_APP', 'WHATSAPP')),
    delivery_status   TEXT NOT NULL CHECK(delivery_status IN ('PENDING', 'SENT', 'FAILED', 'DELIVERED')),
    created_at        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at           DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id)    ON DELETE SET NULL
);
```

**Recommended indexes:**
```sql
CREATE INDEX idx_notifications_account      ON notification_messages(account_id);
CREATE INDEX idx_notifications_status_date  ON notification_messages(delivery_status, created_at);
CREATE INDEX idx_notifications_channel      ON notification_messages(delivery_channel);
```

---

## Implementation notes

### Status transitions

```
PENDING → DELIVERED   (mark as read — only valid transition)
PENDING → SENT        (internal dispatch)
PENDING → FAILED      (internal dispatch failure)
```

All read operations should only act on `PENDING` notifications and be idempotent.

### Security

- Always scope notification queries to the authenticated user's `account_id`
- Validate `message_id` ownership before allowing any write operation
- Return `404` (not `403`) when a notification is not found or belongs to another user, to avoid leaking existence

### Rate limits (recommended)

| Endpoint | Limit |
|----------|-------|
| `GET /list` | 30 req/min per user |
| `GET /unread-count` | 60 req/min per user |
| `PATCH /{message_id}/read` | 60 req/min per user |
| `PATCH /mark-all-read` | 20 req/min per user |

Return `429 Too Many Requests` when exceeded.

### Caching

Cache `unread-count` results per user and invalidate on any read operation to avoid expensive `COUNT` queries on every badge refresh.
