# Activity Diagrams

This document provides the Activity Diagrams for the Customer Ordering System.

The diagrams model:

* workflow behavior
* decision points
* validation logic
* alternate flows
* retry handling
* failure recovery

The activity diagrams are derived from:

* requirements and use cases
* edge case analysis
* system sequence diagrams
* UML class diagram

---

# AD-UC1 — Authentication

```mermaid
flowchart TD

    A([Start]) --> B[Customer submits email and password]

    B --> C{Credentials valid?}

    C -->|No| D[Increment failed login counter]
    D --> E{Failed attempts >= 5?}

    E -->|Yes| F[Lock account for 15 minutes]
    F --> G[Display account locked message]
    G --> Z([End])

    E -->|No| H[Display invalid credentials message]
    H --> Z

    C -->|Yes| I[Create secure session]
    I --> J[Grant system access]
    J --> Z
```

---

# AD-UC2 — Browse Menu

```mermaid
flowchart TD

    A([Start]) --> B[Customer requests menu]

    B --> C[Retrieve menu data]

    C --> D{Database reachable?}

    D -->|No| E[Retry request]
    E --> F{Retries exhausted?}

    F -->|No| C

    F -->|Yes| G[Display menu unavailable message]
    G --> Z([End])

    D -->|Yes| H{Menu contains items?}

    H -->|No| I[Display empty menu message]
    I --> Z

    H -->|Yes| J[Display menu items]
    J --> K[Allow search and filtering]
    K --> Z
```

---

# AD-UC3 — Manage Cart

```mermaid
flowchart TD

    A([Start]) --> B[Customer selects menu item]

    B --> C[Enter quantity]

    C --> D{Quantity valid?}

    D -->|No| E[Display quantity validation error]
    E --> Z([End])

    D -->|Yes| F[Validate stock availability]

    F --> G{Item in stock?}

    G -->|No| H[Display out-of-stock message]
    H --> Z

    G -->|Yes| I[Add or update cart item]
    I --> J[Recalculate cart total]
    J --> K[Update cart display]
    K --> Z
```

---

# AD-UC4 — Place Order

```mermaid
flowchart TD

    A([Start]) --> B[Customer clicks Place Order]

    B --> C{Cart empty?}

    C -->|Yes| D[Reject order request]
    D --> E[Display empty cart message]
    E --> Z([End])

    C -->|No| F[Validate item availability]

    F --> G{Items available?}

    G -->|No| H[Remove unavailable items]
    H --> I[Request customer review cart]
    I --> Z

    G -->|Yes| J[Validate latest prices]

    J --> K{Price changed?}

    K -->|Yes| L[Update prices in cart]
    L --> M[Request customer confirmation]
    M --> Z

    K -->|No| N[Create order]
    N --> O[Generate order ID]
    O --> P[Set order status = PENDING]
    P --> Q[Transition to payment processing]
    Q --> Z
```

---

# AD-UC5 — Process Payment

```mermaid
flowchart TD

    A([Start]) --> B[Customer selects payment method]

    B --> C{HTTPS enabled?}

    C -->|No| D[Reject insecure request]
    D --> Z([End])

    C -->|Yes| E[Send payment request to gateway]

    E --> F{Gateway response received?}

    F -->|No| G[Retry payment request]
    G --> H{Retry attempts exhausted?}

    H -->|No| E

    H -->|Yes| I[Set order status = PAYMENT_FAILED]
    I --> J[Notify customer of payment failure]
    J --> Z

    F -->|Yes| K{Payment approved?}

    K -->|No| L[Display payment declined message]
    L --> Z

    K -->|Yes| M[Record transaction ID]
    M --> N[Update order status = PAID]
    N --> O[Notify customer of successful payment]
    O --> Z
```

---

# AD-UC6 — Send Confirmation

```mermaid
flowchart TD

    A([Start]) --> B[Generate confirmation message]

    B --> C[Send notification]

    C --> D{Notification delivered?}

    D -->|Yes| E[Update order status = CONFIRMED]
    E --> Z([End])

    D -->|No| F[Retry notification delivery]

    F --> G{Retries exhausted?}

    G -->|No| C

    G -->|Yes| H[Store message in notification center]
    H --> I[Log delivery failure]
    I --> E
```

---

# AD-UC7 — Track Order

```mermaid
flowchart TD

    A([Start]) --> B[Customer submits order ID]

    B --> C[Validate customer ownership]

    C --> D{Authorized request?}

    D -->|No| E[Display order not found]
    E --> Z([End])

    D -->|Yes| F[Retrieve current order status]

    F --> G{Order exists?}

    G -->|No| H[Display order not found]
    H --> Z

    G -->|Yes| I[Retrieve status history]
    I --> J[Display tracking timeline]
    J --> Z
```

---

# Design Notes

## Purpose of Activity Diagrams

The activity diagrams model the behavioral workflow of the system.

They describe:

* execution flow
* decisions
* branching logic
* retries
* validation behavior
* operational failure handling

Unlike SSDs, activity diagrams focus on process logic and workflow transitions.

---

## Relationship to Use Cases

Each activity diagram corresponds directly to a use case:

* UC1 → Authentication
* UC2 → Browse Menu
* UC3 → Manage Cart
* UC4 → Place Order
* UC5 → Process Payment
* UC6 → Send Confirmation
* UC7 → Track Order

This preserves traceability between requirements and runtime behavior.

---

## Relationship to Edge Cases

The decision branches and alternate flows are derived from the Edge Case Analysis document.

Examples include:

* invalid credentials
* retry exhaustion
* out-of-stock validation
* payment gateway timeout
* insecure payment requests
* unauthorized order tracking
* invalid quantities

These workflows improve system correctness, security, and reliability.
