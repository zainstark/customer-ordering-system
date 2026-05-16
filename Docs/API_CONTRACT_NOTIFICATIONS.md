# Notifications API Contract

## Overview

This document specifies the API endpoints and data structures for the Notifications feature. The backend should implement these endpoints to integrate with the frontend notifications system.

The notifications system is built on the `notification_messages` database table and supports multi-channel delivery (EMAIL, SMS, IN_APP, WHATSAPP). The frontend focuses on **IN_APP** notifications only.

---

## Base URL

```
/api/notifications
```

---

## Endpoints

### 1. Get Notifications (Paginated)

**Endpoint:** `GET /api/notifications/list`

**Description:** Fetch a paginated list of IN_APP notifications for the authenticated user.

**Query Parameters:**
- `page` (int, required): Page number, starting from 1
- `limit` (int, optional): Number of items per page. Default: 10

**Request Example:**
```
GET /api/notifications/list?page=1&limit=10
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "notifications": [
    {
      "message_id": "msg_001",
      "subject": "Order Delivered",
      "body": "Your burger from Big Bun Grill has been delivered. Enjoy your meal!",
      "delivery_channel": "IN_APP",
      "delivery_status": "PENDING",
      "created_at": "2026-05-16T14:32:00Z",
      "sent_at": "2026-05-16T14:32:00Z",
      "order_id": "order_123"
    },
    {
      "message_id": "msg_002",
      "subject": "Special Discount Available",
      "body": "Get 20% off on your next Sushi order. Valid for today only!",
      "delivery_channel": "IN_APP",
      "delivery_status": "PENDING",
      "created_at": "2026-05-16T13:15:00Z",
      "sent_at": "2026-05-16T13:15:00Z",
      "order_id": null
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 42,
    "totalPages": 5,
    "hasNextPage": true
  }
}
```

**Response Fields:**
- `notifications[]` (array): List of notification objects
  - `message_id` (string): Unique notification identifier (from DB)
  - `subject` (string): Notification title/subject (max 255 chars)
  - `body` (string): Notification message body (max 1000 chars)
  - `delivery_channel` (string): Always "IN_APP" for in-app notifications
  - `delivery_status` (enum): One of: `PENDING`, `SENT`, `FAILED`, `DELIVERED`
    - `PENDING` = unread notification (shown with visual indicator)
    - `DELIVERED` = read notification (delivered successfully)
    - `SENT` = in transit / sent
    - `FAILED` = delivery failed
  - `created_at` (ISO 8601 datetime): When notification was created (UTC)
  - `sent_at` (ISO 8601 datetime, nullable): When notification was sent (UTC)
  - `order_id` (string, optional): Related order ID if applicable
- `pagination.page` (int): Current page
- `pagination.limit` (int): Items per page
- `pagination.total` (int): Total notifications across all pages
- `pagination.totalPages` (int): Total number of pages
- `pagination.hasNextPage` (boolean): Whether there are more pages

**Error Responses:**
```json
// 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "Authentication token is missing or invalid"
}

// 500 Internal Server Error
{
  "error": "InternalServerError",
  "message": "Failed to fetch notifications"
}
```

---

### 2. Get Unread Count

**Endpoint:** `GET /api/notifications/unread-count`

**Description:** Get the count of unread (PENDING status) IN_APP notifications for the authenticated user.

**Request Example:**
```
GET /api/notifications/unread-count
Authorization: Bearer <token>
```

**Response (200 OK):**
```json
{
  "unreadCount": 3
}
```

**Response Fields:**
- `unreadCount` (int): Number of unread notifications (delivery_status = PENDING), 0 or more

**Error Responses:**
```json
// 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "Authentication token is missing or invalid"
}

// 500 Internal Server Error
{
  "error": "InternalServerError",
  "message": "Failed to fetch unread count"
}
```

---

### 3. Mark Notification as Read

**Endpoint:** `PATCH /api/notifications/{message_id}/read`

**Description:** Mark a single IN_APP notification as read by changing status from PENDING to DELIVERED.

**Path Parameters:**
- `message_id` (string, required): Notification message ID

**Request Example:**
```
PATCH /api/notifications/msg_001/read
Authorization: Bearer <token>
Content-Type: application/json
```

**Response (200 OK):**
```json
{
  "message_id": "msg_001",
  "subject": "Order Delivered",
  "body": "Your burger from Big Bun Grill has been delivered. Enjoy your meal!",
  "delivery_channel": "IN_APP",
  "delivery_status": "DELIVERED",
  "created_at": "2026-05-16T14:32:00Z",
  "sent_at": "2026-05-16T14:32:00Z",
  "order_id": "order_123"
}
```

**Response Fields:**
- Same as notification object in GET /list endpoint

**Error Responses:**
```json
// 404 Not Found
{
  "error": "NotFound",
  "message": "Notification not found"
}

// 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "Authentication token is missing or invalid"
}

// 500 Internal Server Error
{
  "error": "InternalServerError",
  "message": "Failed to mark notification as read"
}
```

---

### 4. Mark All Notifications as Read

**Endpoint:** `PATCH /api/notifications/mark-all-read`

**Description:** Mark all IN_APP notifications as read by changing status from PENDING to DELIVERED for the authenticated user.

**Request Example:**
```
PATCH /api/notifications/mark-all-read
Authorization: Bearer <token>
Content-Type: application/json
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "markedCount": 5
}
```

**Response Fields:**
- `success` (boolean): Whether operation was successful
- `message` (string): Success message
- `markedCount` (int): Number of notifications that were marked as read

**Error Responses:**
```json
// 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "Authentication token is missing or invalid"
}

// 500 Internal Server Error
{
  "error": "InternalServerError",
  "message": "Failed to mark all notifications as read"
}
```

---

## Data Types

### Notification Object

```typescript
interface Notification {
  message_id: string;           // UUID or unique identifier (PK from DB)
  subject: string;              // Max 255 characters
  body: string;                 // Max 1000 characters
  delivery_channel: "IN_APP";   // Always IN_APP for in-app notifications
  delivery_status: "PENDING" | "SENT" | "DELIVERED" | "FAILED";
  created_at: string;           // ISO 8601 datetime (UTC)
  sent_at?: string;             // ISO 8601 datetime (UTC), nullable
  order_id?: string;            // Optional FK to orders table
}
```

### Delivery Status Values

- `PENDING` = Unread notification (user hasn't seen it yet)
- `SENT` = Notification sent but not confirmed delivered
- `DELIVERED` = Successfully delivered and read by user
- `FAILED` = Delivery failed

**For the UI:** Use `PENDING` status to identify unread notifications.

---

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request (invalid query parameters) |
| 401 | Unauthorized (missing/invalid token) |
| 404 | Not Found (notification ID doesn't exist) |
| 500 | Internal Server Error |

---

## Authentication

All endpoints require authentication via Bearer token in the `Authorization` header:

```
Authorization: Bearer <JWT_TOKEN>
```

The backend should validate the token and return a 401 error if invalid or expired. Ensure notifications are filtered by the authenticated user's `account_id`.

---

## Rate Limiting (Optional)

Recommended rate limits to prevent abuse:

- `GET /list`: 30 requests per minute per user
- `GET /unread-count`: 60 requests per minute per user
- `PATCH /{message_id}/read`: 60 requests per minute per user
- `PATCH /mark-all-read`: 20 requests per minute per user

Return `429 Too Many Requests` if limits are exceeded.

---

## Implementation Notes for Backend Developers

1. **IN_APP Channel Only:** The frontend consumes IN_APP notifications. Filter `delivery_channel = 'IN_APP'` in all endpoints.

2. **User Isolation:** Always filter notifications by the authenticated user's `account_id` to prevent cross-user access.

3. **Pagination:** Ensure consistent pagination across all endpoints. Return `hasNextPage` to help frontend determine when to stop fetching.

4. **Timestamps:** Always use ISO 8601 format with UTC timezone. Example: `2026-05-16T14:32:00Z`

5. **Sorting:** Return notifications sorted by `created_at` in descending order (newest first).

6. **Status Transitions:**
   - When creating a notification: set `delivery_status = 'PENDING'` and `sent_at` to current timestamp
   - When user marks as read: update `delivery_status = 'DELIVERED'`
   - Only allow PENDING → DELIVERED transitions (idempotent)

7. **Order Relations:** If `order_id` is present, the notification relates to that order. Use it for context in the UI.

8. **Validation:** 
   - Validate that notification belongs to authenticated user before allowing read operations
   - Validate message_id format and existence before processing

9. **Soft Delete:** Consider soft-deleting notifications instead of hard deletes for audit trails.

10. **Database Indexing:** Ensure indexes on:
    - `notification_messages(account_id)`
    - `notification_messages(delivery_status, created_at)`
    - `notification_messages(delivery_channel)`

11. **Caching:** Cache unread count to avoid expensive queries on every request. Invalidate on read operations.

---

## Database Schema Reference

```sql
CREATE TABLE notification_messages (
    message_id TEXT PRIMARY KEY,
    account_id TEXT NOT NULL,
    order_id TEXT,
    subject TEXT,
    body TEXT,
    delivery_channel TEXT NOT NULL
        CHECK(delivery_channel IN ('EMAIL', 'SMS', 'IN_APP', 'WHATSAPP')),
    delivery_status TEXT NOT NULL
        CHECK(delivery_status IN ('PENDING', 'SENT', 'FAILED', 'DELIVERED')),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL
);
```

---

## WebSocket/Real-Time Support (Future)

For real-time notifications, the backend can emit WebSocket events:

```json
{
  "event": "notification.new",
  "data": {
    "message_id": "msg_125",
    "subject": "New Order",
    "body": "You have a new order from Pizza Palace",
    "delivery_channel": "IN_APP",
    "delivery_status": "PENDING",
    "created_at": "2026-05-16T15:45:00Z",
    "sent_at": "2026-05-16T15:45:00Z",
    "order_id": "order_999"
  }
}
```

This allows the frontend to update in real-time without polling.

---

## Example Integration Flow

1. **App Launch:**
   - Call `GET /unread-count` to show badge
   - Call `GET /list?page=1` to populate popup

2. **User Taps Notification (Popup or Page):**
   - Call `PATCH /{message_id}/read` to mark as read
   - Update local UI immediately
   - Badge count decrements by 1

3. **User Taps "Show All Notifications":**
   - Navigate to notifications page
   - Display first page from earlier call (cached)
   - As user scrolls, call `GET /list?page=2`, etc.

4. **User Taps "Mark All as Read" (Page):**
   - Call `PATCH /mark-all-read`
   - Update all local notifications to DELIVERED status
   - Reset unread count badge to 0

---

## Testing Checklist

- [ ] Verify pagination returns correct `hasNextPage` flag
- [ ] Verify unread count is accurate (counts only PENDING status)
- [ ] Verify mark-as-read updates notification status to DELIVERED
- [ ] Verify mark-all-read processes correctly
- [ ] Verify error responses with correct status codes
- [ ] Verify authentication failures return 401
- [ ] Verify timestamps are in ISO 8601 UTC format
- [ ] Verify notifications are filtered by authenticated user only
- [ ] Verify IN_APP channel filtering works correctly
- [ ] Test with 0 notifications
- [ ] Test with 1000+ notifications
- [ ] Verify order_id filtering works when provided
- [ ] Verify pagination limit respects backend max (e.g., max 100 per page)
