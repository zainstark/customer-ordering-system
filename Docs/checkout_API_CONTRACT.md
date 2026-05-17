# Checkout API Contract (Current Backend)

## Authentication

All checkout/cart/order/payment endpoints below require JWT bearer auth:

```http
Authorization: Bearer <access_token>
```

The backend reads `account_id` from the token (`request.user.account_id`), not from request body/query.

## Endpoints

### GET /api/cart/

Response `200`:

```json
{
  "cartId": "string",
  "accountId": "string",
  "items": [
    {
      "id": "string",
      "cartId": "string",
      "menuItemId": "string",
      "title": "string",
      "subtitle": "string",
      "unitPrice": 0.0,
      "quantity": 1,
      "imageUrl": "string"
    }
  ],
  "itemCount": 0,
  "cartTotal": 0.0
}
```

### POST /api/cart/validate/

Response `200`:

```json
{
  "is_valid": true,
  "issues": [],
  "cart_id": "string"
}
```

### Order placement

Checkout consumes an existing order and does not define order-placement fields here.

Use `Docs/order_API_CONTRACT.md` as the source of truth for order creation/listing.

### POST /api/payments/create-session/

Request (snake_case preferred, camelCase aliases accepted):

```json
{
  "order_id": "string",
  "payment_method": "CARD"
}
```

Response `201`:

```json
{
  "payment_id": "string",
  "payment_intent_id": "string",
  "client_secret": "string",
  "checkout_url": "string",
  "status": "INITIATED",
  "paymentId": "string",
  "checkoutUrl": "string"
}
```

### GET /api/payments/{payment_id}/status/

Response `200`:

```json
{
  "payment_id": "string",
  "paymentId": "string",
  "order_id": "string",
  "orderId": "string",
  "status": "INITIATED",
  "amount": 0.0,
  "payment_method": "CARD",
  "paymentMethod": "CARD",
  "message": null
}
```

### POST /api/payments/{payment_id}/retry/

Response `200`:

```json
{
  "payment_id": "string",
  "paymentId": "string",
  "status": "INITIATED",
  "message": "Retry initiated.",
  "retryCount": 1
}
```

### POST /api/payments/webhook/

Required header:

```http
Stripe-Signature: <signature>
```

Response `200` on valid processing, `400` on invalid signature/payload.
