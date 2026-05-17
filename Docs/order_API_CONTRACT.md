
# Order API Contract

This document defines the API contract for the Order module of the Customer Ordering System.

The API supports:

* listing orders for the authenticated account
* placing a new order from the current cart

All endpoints require JWT authentication.

---

# Base URL

```http
/api/order/
```

---

# Authentication

All order endpoints require a valid JWT bearer token.

## Header

```http
Authorization: Bearer <JWT_TOKEN>
```

Unauthorized requests return:

```json
{
  "detail": "Authentication credentials were not provided."
}
```

Status Code:

```http
401 Unauthorized
```

---

# Data Models

## Order Response Structure

```json
{
  "orderId": "4a9122b7-c2da-4a2e-8261-8bf4d8d2c56d",
  "accountId": "a6979ecc-f173-4dcf-9954-87b0c9e6e992",
  "status": "PENDING",
  "placedAt": "2026-05-17T11:43:56.840730Z",
  "totalAmount": 666.0,
  "progress": 0.1,
  "items": [
    {
      "id": "37dcfa17-62c2-40b1-816d-565cf1624e87",
      "title": "Cheeseburger",
      "unitPrice": 111.0,
      "quantity": 6,
      "lineTotal": 666.0
    }
  ]
}
```

---

## Order Item Structure

```json
{
  "id": "37dcfa17-62c2-40b1-816d-565cf1624e87",
  "title": "Cheeseburger",
  "unitPrice": 111.0,
  "quantity": 6,
  "lineTotal": 666.0
}
```

---

## Field Descriptions

### Order Fields

| Field       | Type     | Description                                        |
| ----------- | -------- | -------------------------------------------------- |
| orderId     | string   | UUID — unique order identifier                     |
| accountId   | string   | UUID — account that owns the order                 |
| status      | string   | Current order status (see Status Values below)     |
| placedAt    | string   | ISO-8601 datetime when the order was placed        |
| totalAmount | float    | Total amount in dollars (DB stores pennies ÷ 100)  |
| progress    | float    | Progress value 0.0–1.0 derived from order status   |
| items       | array    | List of order item line objects                     |

### Order Item Fields

| Field     | Type    | Description                                           |
| --------- | ------- | ----------------------------------------------------- |
| id        | string  | UUID — unique order item identifier                   |
| title     | string  | Menu item name snapshot at time of order               |
| unitPrice | float   | Unit price in dollars snapshot at time of order         |
| quantity  | integer | Number of units ordered                                |
| lineTotal | float   | Line total in dollars (unitPrice × quantity)            |

---

## Order Status Values

| Status           | Progress | Description                          |
| ---------------- | -------- | ------------------------------------ |
| PENDING          | 0.1      | Order placed, awaiting confirmation  |
| CONFIRMED        | 0.25     | Order confirmed by the restaurant    |
| PREPARING        | 0.5      | Order is being prepared              |
| READY            | 0.75     | Order is ready for pickup/delivery   |
| OUT_FOR_DELIVERY | 0.9      | Order is out for delivery            |
| DELIVERED        | 1.0      | Order has been delivered             |
| CANCELLED        | 0.0      | Order was cancelled                  |
| REFUNDED         | 0.0      | Order was refunded                   |
| FAILED           | 0.0      | Order placement failed               |

---

# 1. List Orders

Retrieve all orders belonging to the authenticated user, newest first.

## Endpoint

```http
GET /api/order/
```

---

## Request Headers

```http
Authorization: Bearer <JWT_TOKEN>
```

---

## Successful Response

### Status Code

```http
200 OK
```

### Response Body (with orders)

```json
[
  {
    "orderId": "4a9122b7-c2da-4a2e-8261-8bf4d8d2c56d",
    "accountId": "a6979ecc-f173-4dcf-9954-87b0c9e6e992",
    "status": "PENDING",
    "placedAt": "2026-05-17T11:43:56.840730Z",
    "totalAmount": 666.0,
    "progress": 0.1,
    "items": [
      {
        "id": "37dcfa17-62c2-40b1-816d-565cf1624e87",
        "title": "Cheeseburger",
        "unitPrice": 111.0,
        "quantity": 6,
        "lineTotal": 666.0
      }
    ]
  }
]
```

### Response Body (no orders)

```json
[]
```

---

## Error Responses

### Unauthorized

```http
401 Unauthorized
```

```json
{
  "detail": "Authentication credentials were not provided."
}
```

---

# 2. Place Order

Convert the authenticated user's current cart into a new order.

## Endpoint

```http
POST /api/order/place/
```

---

## Request Headers

```http
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

---

## Request Body

```json
{
  "address": "123 Test Street, Cairo"
}
```

---

## Request Body Fields

| Field   | Type   | Required | Validation           |
| ------- | ------ | -------- | -------------------- |
| address | string | Yes      | Max 500 characters   |

---

## Validation Rules

| Rule                | Description                                                       |
| ------------------- | ----------------------------------------------------------------- |
| Address required    | Request must include a non-empty `address` field                  |
| Cart must exist     | The authenticated account must have an existing cart               |
| Cart must not be empty | The cart must contain at least one item                        |
| Items must be available | All menu items in the cart must still be available            |
| Pricing from DB     | Total is computed from live DB prices, never from cart snapshots   |

---

## Successful Response

### Status Code

```http
201 Created
```

### Response Body

```json
{
  "orderId": "4a9122b7-c2da-4a2e-8261-8bf4d8d2c56d",
  "accountId": "a6979ecc-f173-4dcf-9954-87b0c9e6e992",
  "status": "PENDING",
  "placedAt": "2026-05-17T11:43:56.840730Z",
  "totalAmount": 666.0,
  "progress": 0.1,
  "items": [
    {
      "id": "37dcfa17-62c2-40b1-816d-565cf1624e87",
      "title": "Cheeseburger",
      "unitPrice": 111.0,
      "quantity": 6,
      "lineTotal": 666.0
    }
  ]
}
```

---

## Error Responses

### Missing Address

```http
400 Bad Request
```

```json
{
  "address": [
    "This field is required."
  ]
}
```

---

### No Cart Found

```http
400 Bad Request
```

```json
{
  "error": "No cart found for this account."
}
```

---

### Empty Cart

```http
400 Bad Request
```

```json
{
  "error": "Cannot place an order with an empty cart."
}
```

---

### Unavailable Item

```http
400 Bad Request
```

```json
{
  "error": "Item 'Cheeseburger' is no longer available."
}
```

---

### Unauthorized

```http
401 Unauthorized
```

```json
{
  "detail": "Authentication credentials were not provided."
}
```

---

# Security Considerations

## Authentication

All endpoints require authenticated JWT tokens.

The API derives the account identity from the JWT token instead of trusting client-supplied account IDs.

---

## Authorization

Order operations are restricted to the order owner only.

* `GET /api/order/` returns only the authenticated user's orders.
* `POST /api/order/place/` creates an order for the authenticated user only.
* Supplying an `account_id` in the request body or query parameters is silently ignored.

---

## Price Tampering Prevention

The service always computes `totalAmount` from live database prices, never from the cart's price snapshots. This prevents clients from injecting lower prices.

---

## Idempotency Guard

If a `PENDING` or `CONFIRMED` order already exists for the same account within a 30-second window, the API returns the existing order instead of creating a duplicate. This protects against double-click and network retry scenarios.

---

# Business Rules

| Rule                       | Description                                                            |
| -------------------------- | ---------------------------------------------------------------------- |
| Cart-to-order conversion   | Placing an order converts the cart into an order                       |
| Cart cleared on success    | The cart is emptied after a successful order placement                  |
| Cart preserved on failure  | If placement fails, the cart is preserved for correction                |
| Atomic transaction         | All order creation steps run inside a single DB transaction             |
| Rollback on failure        | If any step fails, all DB writes are rolled back                       |
| Snapshot pricing           | Order items store the item name, description, and price at order time  |
| Live price totals          | The order total is always computed from live DB prices                  |
| Idempotency window         | 30-second guard prevents duplicate orders                              |
| Newest first               | List orders returns results sorted by `placed_at` descending           |
| One order per placement    | Each placement call produces at most one order                         |

---

# Error Handling

## Standard Error Format

```json
{
  "error": "Descriptive error message"
}
```

---

## Validation Error Format

```json
{
  "field_name": [
    "Validation message"
  ]
}
```

---

# HTTP Status Codes

| Status Code               | Meaning                               |
| ------------------------- | ------------------------------------- |
| 200 OK                    | Request successful                    |
| 201 Created               | Order created successfully            |
| 400 Bad Request           | Invalid request or validation failure |
| 401 Unauthorized          | Missing or invalid authentication     |
| 500 Internal Server Error | Unexpected server error               |

---

# Traceability

This API contract supports the following use cases:

| Use Case | Description  |
| -------- | ------------ |
| UC4      | Place Order  |
| UC7      | View Orders  |

The API behavior also aligns with the Edge Case Analysis document, including:

* EC-UC4-01 — empty cart placement prevention
* EC-UC4-02 — duplicate order idempotency guard
* EC-UC4-04 — price tampering prevention (live DB pricing)
* EC-UC3-01 — unavailable item validation
* EC-UC7-01 — order isolation between accounts
