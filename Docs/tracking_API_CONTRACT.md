# Tracking API Contract

## Overview

This document defines the API contract for **order tracking**, aligned with the system requirements (FR8, FR9) and use case UC7. It integrates with existing services (Menu, Cart, Orders, Payment).

---

## Base URL

```
/api
```

---

## Endpoint: Get Order Tracking

### Description

Retrieve the current tracking status of an order along with progress, estimated time, and history.

### HTTP Method

```
GET /orders/{orderId}/tracking
```

---

## Path Parameters

| Name    | Type   | Required | Description             |
| ------- | ------ | -------- | ----------------------- |
| orderId | string | Yes      | Unique order identifier |

---

## Response

### Success Response (200 OK)

```json
{
  "orderId": "ORD-001",
  "currentStatus": "preparing",
  "progress": 50,
  "estimatedTimeMinutes": 15,
  "history": [
    {
      "status": "pending",
      "timestamp": "2026-05-18T12:00:00Z"
    },
    {
      "status": "confirmed",
      "timestamp": "2026-05-18T12:01:30Z"
    },
    {
      "status": "preparing",
      "timestamp": "2026-05-18T12:05:00Z"
    }
  ]
}
```

---

## Tracking Status Lifecycle

The order status MUST follow this sequence:

```
pending → confirmed → preparing → ready → delivery → delivered
```

---

## Status Definitions

| Status    | Description                            |
| --------- | -------------------------------------- |
| pending   | Order created, awaiting payment        |
| confirmed | Payment successful and order confirmed |
| preparing | Order is being prepared                |
| ready     | Order is ready for pickup/delivery     |
| delivery  | Order is out for delivery              |
| delivered | Order successfully delivered           |

---

## Progress Mapping

| Status    | Progress |
| --------- | -------- |
| pending   | 0%       |
| confirmed | 20%      |
| preparing | 50%      |
| ready     | 70%      |
| delivery  | 90%      |
| delivered | 100%     |

---

## Error Responses

### 404 Not Found

```json
{
  "message": "Order not found",
  "statusCode": 404
}
```

### 400 Bad Request

```json
{
  "message": "Invalid order ID",
  "statusCode": 400
}
```

---

## Performance Requirements

* Response time must be ≤ 2 seconds (NFR1)
* System should return the latest known status if real-time update is unavailable

---

## Integration with Other Services

### Order Service

* Provides `orderId`
* Initializes status = `pending`

### Payment Service

* On success → updates status to `confirmed`

### Kitchen / Preparation System

* Updates status:

  * `preparing`
  * `ready`

### Delivery System

* Updates status:

  * `delivery`
  * `delivered`

---

## Notes

* This endpoint is **read-only** (GET only)
* Status updates are handled internally by the system (FR8)
* Supports frontend UI features:

  * Progress bar (`progress`)
  * Timeline (`history`)
  * ETA display (`estimatedTimeMinutes`)

---