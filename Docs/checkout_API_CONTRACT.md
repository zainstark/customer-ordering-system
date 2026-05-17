# Checkout API Contract

## Endpoints

### POST /api/cart/validate/
Request:
- account_id: string

Response:
- items: [
  {
    id: string,
    cartId: string,
    menuItemId: string,
    title: string,
    subtitle: string,
    unitPrice: number,
    quantity: number,
    imageUrl: string,
  }
]

### POST /api/orders/
Request:
- account_id: string
- payment_method: string
- amount: number
- items: [
  {
    id: string,
    cartId: string,
    menuItemId: string,
    title: string,
    subtitle: string,
    unitPrice: number,
    quantity: number,
    imageUrl: string,
  }
]

Response:
- order_id: string
- amount: number
- reference: string

### POST /api/payments/create-session/
Request:
- order_id: string
- payment_method: string
- amount: number

Response:
- payment_id: string
- checkout_url: string
- status: string

### GET /api/payments/{paymentId}/status/
Response:
- payment_id: string
- status: string
- message?: string

### POST /api/payments/{paymentId}/retry/
Response:
- payment_id: string
- status: string
- message?: string

## Notes
- The frontend currently uses a mock checkout remote data source to simulate delays and payment outcomes.
- The repository and use-case structure are designed so the mock layer can be replaced with a real backend implementation without UI changes.
