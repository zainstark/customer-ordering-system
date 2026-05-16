# System Sequence Diagrams (SSD)

This document provides the System Sequence Diagrams (SSD) for the Customer Ordering System.

The SSDs describe:

* external actors
* interactions with the system
* system responses
* alternate and failure flows

The diagrams are derived from:

* requirements and use cases
* UML class diagram
* edge case analysis

---

# SSD-UC1 — Authentication

```mermaid
sequenceDiagram

actor Customer
participant System as Customer Ordering System

Customer->>System: Submit(email,password)

System->>System: Validate credentials

alt Valid credentials
    System->>System: Create secure session
    System-->>Customer: Login successful
else Invalid credentials
    System-->>Customer: "Invalid email or password"
else Account locked
    System-->>Customer: "Account temporarily locked"
end
```

---

# SSD-UC2 — Browse Menu

```mermaid
sequenceDiagram

actor Customer
participant System as Customer Ordering System
participant Database as Menu Database

Customer->>System: Request menu

System->>Database: Retrieve menu items

alt Menu retrieved successfully
    Database-->>System: Menu data
    System-->>Customer: Display menu items
else Database unavailable
    System->>Database: Retry request (2 attempts)

    alt Retry successful
        Database-->>System: Menu data
        System-->>Customer: Display menu items
    else Retry exhausted
        System-->>Customer: "Unable to load menu"
    end
end
```

---

# SSD-UC3 — Manage Cart

```mermaid
sequenceDiagram

actor Customer
participant System as Customer Ordering System

Customer->>System: Add item(menuItemId, quantity)

System->>System: Validate quantity
System->>System: Validate stock availability

alt Item available and quantity valid
    System->>System: Add/update cart item
    System->>System: Recalculate total
    System-->>Customer: Updated cart
else Out of stock
    System-->>Customer: "Item out of stock"
else Invalid quantity
    System-->>Customer: "Quantity must be at least 1"
end
```

---

# SSD-UC4 — Place Order

```mermaid
sequenceDiagram

actor Customer
participant System as Customer Ordering System

Customer->>System: Place order(cartId)

System->>System: Validate cart contents
System->>System: Validate item availability
System->>System: Validate pricing

alt Cart valid
    System->>System: Create order
    System->>System: Generate order ID
    System-->>Customer: Order created(orderId)
else Empty cart
    System-->>Customer: "Order cannot be placed with an empty cart"
else Price changed
    System-->>Customer: "Item price has changed"
else Item unavailable
    System-->>Customer: "Item no longer available"
end
```

---

# SSD-UC5 — Process Payment

```mermaid
sequenceDiagram

actor Customer
participant System as Customer Ordering System
participant Gateway as External Payment Gateway

Customer->>System: Submit payment details

System->>System: Validate HTTPS connection
System->>Gateway: Authorize payment(amount)

alt Payment authorized
    Gateway-->>System: Transaction approved(transactionId)
    System->>System: Record transaction
    System->>System: Update order status = PAID
    System-->>Customer: Payment successful

else Payment declined
    Gateway-->>System: Payment declined
    System-->>Customer: "Payment failed"

else Gateway timeout
    System->>Gateway: Retry payment (up to 3 attempts)

    alt Retry successful
        Gateway-->>System: Transaction approved
        System-->>Customer: Payment successful
    else Retry exhausted
        System->>System: Mark order = PAYMENT_FAILED
        System-->>Customer: "Payment could not be completed"
    end
end
```

---

# SSD-UC6 — Send Confirmation

```mermaid
sequenceDiagram

participant System as Customer Ordering System
participant Notification as Notification Service
actor Customer

System->>Notification: Send confirmation(orderId)

alt Delivery successful
    Notification-->>Customer: Confirmation message
    System->>System: Update order status = CONFIRMED

else Delivery failed
    Notification->>Notification: Retry delivery (3 attempts)

    alt Retry successful
        Notification-->>Customer: Confirmation message
    else Retry exhausted
        System->>System: Store in notification center
        System->>System: Log delivery failure
    end
end
```

---

# SSD-UC7 — Track Order

```mermaid
sequenceDiagram

actor Customer
participant System as Customer Ordering System

Customer->>System: Request order status(orderId)

System->>System: Validate ownership
System->>System: Retrieve current status
System->>System: Retrieve status history

alt Order found
    System-->>Customer: Current status + history
else Invalid order ID
    System-->>Customer: "Order not found"
else Unauthorized access
    System-->>Customer: "Order not found"
end
```

---

# Design Notes

## Purpose of SSDs

The System Sequence Diagrams describe:

* how actors interact with the system
* the order of operations
* major validation points
* failure handling behavior

Unlike class diagrams, SSDs focus on runtime interaction flow rather than internal structure.

---

## Relationship to Requirements

Each SSD corresponds directly to a use case:

* UC1 → Authentication
* UC2 → Browse Menu
* UC3 → Manage Cart
* UC4 → Place Order
* UC5 → Process Payment
* UC6 → Send Confirmation
* UC7 → Track Order

This preserves traceability between:

* requirements
* behavior
* implementation

---

## Relationship to Edge Cases

Alternative and failure flows were derived from the Edge Case Analysis document.

Examples include:

* invalid credentials
* out-of-stock items
* payment gateway timeout
* duplicate requests
* unauthorized order access

These flows improve reliability, security, and operational correctness.
