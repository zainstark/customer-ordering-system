
# Cart API Contract

This document defines the API contract for the Cart module of the Customer Ordering System.

The API supports:

* retrieving carts
* adding items
* updating quantities
* removing items
* validating cart consistency
* clearing carts

All endpoints require JWT authentication.

---

# Base URL

```http
/api/cart/
```

---

# Authentication

All cart endpoints require a valid JWT bearer token.

## Header

```http
Authorization: Bearer <JWT_TOKEN>
```

Unauthorized requests return:

```json
{
  "error": "Authentication token is required"
}
```

Status Code:

```http
401 Unauthorized
```

---

# Data Model

## Cart Response Structure

```json
{
  "cartId": "cart_001",
  "accountId": "acct_001",
  "items": [
    {
      "id": "item_001",
      "cartId": "cart_001",
      "menuItemId": "menu_001",
      "title": "Margherita Pizza",
      "subtitle": "Classic pizza with tomato and mozzarella",
      "unitPrice": 15.99,
      "quantity": 2,
      "imageUrl": "https://example.com/pizza.jpg"
    }
  ],
  "itemCount": 2,
  "cartTotal": 31.98
}
```

---

# 1. Get Cart

Retrieve the authenticated user's cart.

## Endpoint

```http
GET /api/cart/
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

### Response Body

```json
{
  "cartId": "cart_001",
  "accountId": "acct_001",
  "items": [],
  "itemCount": 0,
  "cartTotal": 0.0
}
```

---

## Error Responses

### Unauthorized

```http
401 Unauthorized
```

```json
{
  "error": "Authentication token is required"
}
```

---

# 2. Add Item to Cart

Add a menu item to the authenticated user's cart.

## Endpoint

```http
POST /api/cart/items/
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
  "menu_item_id": "menu_001",
  "quantity": 2
}
```

---

## Validation Rules

| Field        | Rule                                 |
| ------------ | ------------------------------------ |
| menu_item_id | Must reference an existing menu item |
| quantity     | Must be greater than 0               |
| menu item    | Must be available                    |

---

## Successful Response

### Status Code

```http
201 Created
```

### Response Body

```json
{
  "cartId": "cart_001",
  "accountId": "acct_001",
  "items": [
    {
      "id": "item_001",
      "cartId": "cart_001",
      "menuItemId": "menu_001",
      "title": "Margherita Pizza",
      "subtitle": "Classic pizza with tomato and mozzarella",
      "unitPrice": 15.99,
      "quantity": 2,
      "imageUrl": "https://example.com/pizza.jpg"
    }
  ],
  "itemCount": 2,
  "cartTotal": 31.98
}
```

---

## Error Responses

### Invalid Quantity

```http
400 Bad Request
```

```json
{
  "quantity": [
    "Ensure this value is greater than or equal to 1."
  ]
}
```

---

### Menu Item Not Found

```http
400 Bad Request
```

```json
{
  "error": "Menu item menu_001 not found"
}
```

---

### Item Out of Stock

```http
400 Bad Request
```

```json
{
  "error": "Menu item Margherita Pizza is out of stock"
}
```

---

# 3. Update Cart Item Quantity

Update the quantity of an existing cart item.

## Endpoint

```http
PATCH /api/cart/items/{cart_item_id}/
```

---

## Path Parameters

| Parameter    | Description                 |
| ------------ | --------------------------- |
| cart_item_id | Unique cart item identifier |

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
  "quantity": 3
}
```

---

## Successful Response

### Status Code

```http
200 OK
```

### Response Body

```json
{
  "cartId": "cart_001",
  "accountId": "acct_001",
  "items": [
    {
      "id": "item_001",
      "cartId": "cart_001",
      "menuItemId": "menu_001",
      "title": "Margherita Pizza",
      "subtitle": "Classic pizza with tomato and mozzarella",
      "unitPrice": 15.99,
      "quantity": 3,
      "imageUrl": "https://example.com/pizza.jpg"
    }
  ],
  "itemCount": 3,
  "cartTotal": 47.97
}
```

---

## Error Responses

### Invalid Quantity

```http
400 Bad Request
```

```json
{
  "quantity": [
    "Ensure this value is greater than or equal to 1."
  ]
}
```

---

### Cart Item Not Found

```http
404 Not Found
```

```json
{
  "error": "Cart item item_001 not found"
}
```

---

### Unauthorized Access

```http
404 Not Found
```

```json
{
  "error": "Cart item item_001 not found"
}
```

The API intentionally returns the same response for unauthorized and nonexistent resources to prevent resource enumeration.

---

# 4. Remove Item from Cart

Remove an item from the authenticated user's cart.

## Endpoint

```http
DELETE /api/cart/items/{cart_item_id}/delete/
```

---

## Path Parameters

| Parameter    | Description                 |
| ------------ | --------------------------- |
| cart_item_id | Unique cart item identifier |

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

### Response Body

```json
{
  "cartId": "cart_001",
  "accountId": "acct_001",
  "items": [],
  "itemCount": 0,
  "cartTotal": 0.0
}
```

---

## Error Responses

### Cart Item Not Found

```http
404 Not Found
```

```json
{
  "error": "Cart item item_001 not found"
}
```

---

# 5. Validate Cart

Validate cart consistency including:

* item availability
* menu item existence
* pricing consistency

## Endpoint

```http
POST /api/cart/validate/
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

### Valid Cart

```json
{
  "is_valid": true,
  "issues": [],
  "cart_id": "cart_001"
}
```

---

### Invalid Cart

```json
{
  "is_valid": false,
  "issues": [
    {
      "cart_item_id": "item_001",
      "menu_item_id": "menu_001",
      "name": "Margherita Pizza",
      "issue": "Price has changed",
      "old_price": 1500,
      "new_price": 1700
    }
  ],
  "cart_id": "cart_001"
}
```

---

## Validation Conditions

The system validates:

| Validation          | Description                     |
| ------------------- | ------------------------------- |
| Menu item existence | Item still exists in menu       |
| Availability        | Item is still available         |
| Price consistency   | Price matches latest menu price |

---

# 6. Clear Cart

Remove all items from the authenticated user's cart.

## Endpoint

```http
DELETE /api/cart/clear/
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

### Response Body

```json
{
  "cartId": "cart_001",
  "accountId": "acct_001",
  "items": [],
  "itemCount": 0,
  "cartTotal": 0.0
}
```

---

# Security Considerations

## Authentication

All endpoints require authenticated JWT tokens.

The API derives the account identity from the JWT token instead of trusting client-supplied account IDs.

---

## Authorization

Cart operations are restricted to cart owners only.

Attempts to access another user's cart item return:

```http
404 Not Found
```

instead of:

```http
403 Forbidden
```

This prevents resource enumeration attacks.

---

## Input Validation

The API validates:

* quantity positivity
* menu item existence
* stock availability
* pricing consistency

Invalid requests are rejected before database modification.

---

# Business Rules

| Rule                 | Description                                     |
| -------------------- | ----------------------------------------------- |
| One cart per account | Each account owns a single active cart          |
| Quantity validation  | Quantities must be greater than zero            |
| Snapshot pricing     | Cart items store immutable price snapshots      |
| Cart ownership       | Users cannot access other carts                 |
| Cart recalculation   | Totals update automatically after modifications |

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
| 201 Created               | Resource created successfully         |
| 400 Bad Request           | Invalid request or validation failure |
| 401 Unauthorized          | Missing or invalid authentication     |
| 404 Not Found             | Resource not found or unauthorized    |
| 500 Internal Server Error | Unexpected server error               |

---

# Traceability

This API contract supports the following use cases:

| Use Case | Description |
| -------- | ----------- |
| UC3      | Manage Cart |
| UC4      | Place Order |

The API behavior also aligns with the Edge Case Analysis document, including:

* invalid quantities
* unavailable items
* price changes
* unauthorized access prevention
* validation consistency
* cart ownership enforcement
