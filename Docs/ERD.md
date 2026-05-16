# ERD / Schema Plan

This ERD is derived from the UML class diagram and keeps only the persistent data model needed to support the requirements and use cases.

## ER Diagram

```mermaid
erDiagram

  accounts {
    text account_id PK
    text display_name
    text email UK
    text role
    text password_hash
    text phone_number
    bool active
    datetime created_at
    datetime updated_at
  }

  menu_catalogs {
    text catalog_id PK
    text name
    bool active
    datetime created_at
    datetime updated_at
  }

  categories {
    text category_id PK
    text category_name
    text description
    datetime created_at
    datetime updated_at
  }

  menu_items {
    text menu_item_id PK
    text catalog_id FK
    text category_id FK
    text name
    text description
    int price_penny
    bool available
    text image_url
    datetime created_at
    datetime updated_at
  }

  carts {
    text cart_id PK
    text account_id FK
    datetime created_at
    datetime updated_at
  }

  cart_items {
    text cart_item_id PK
    text cart_id FK
    text menu_item_id FK
    int quantity
    int unit_price_snapshot
    int line_total
    datetime created_at
    datetime updated_at
  }

  orders {
    text order_id PK
    text account_id FK
    int total_amount
    datetime placed_at
    text order_status
    datetime confirmed_at
    text address
    datetime updated_at
  }

  order_items {
    text order_item_id PK
    text order_id FK
    text menu_item_id FK
    text item_name_snapshot
    text item_description_snapshot
    int unit_price_snapshot
    int quantity
    int line_total
  }

  payments {
    text payment_id PK
    text order_id FK
    int amount
    datetime initiated_at
    datetime processed_at
    text payment_method
    text payment_status
  }

  transactions {
    text transaction_id PK
    text payment_id FK
    text gateway_reference
    text authorization_code
    datetime processed_at
  }

  order_status_history {
    text history_id PK
    text order_id FK
    text order_status
    text note
    datetime changed_at
  }

  notification_messages {
    text message_id PK
    text account_id FK
    text order_id FK
    text subject
    text body
    text delivery_channel
    text delivery_status
    datetime created_at
    datetime sent_at
  }

  auth_user {
    int id PK
    text username
    text email
    text password
    bool is_staff
    bool is_active
  }

  token_blacklist_outstandingtoken {
    int id PK
    text jti UK
    text token
    int user_id FK
    datetime created_at
    datetime expires_at
  }

  token_blacklist_blacklistedtoken {
    int id PK
    int outstanding_token_id FK
    datetime blacklisted_at
  }

  accounts ||--|| carts : "account_id"
  accounts ||--o{ orders : "account_id"
  accounts ||--o{ notification_messages : "account_id"

  menu_catalogs ||--o{ menu_items : "catalog_id"
  categories ||--o{ menu_items : "category_id"

  carts ||--o{ cart_items : "cart_id"
  menu_items ||--o{ cart_items : "menu_item_id"
  menu_items ||--o{ order_items : "menu_item_id"

  orders ||--o{ order_items : "order_id"
  orders ||--o{ payments : "order_id"
  orders ||--o{ order_status_history : "order_id"
  orders ||--o{ notification_messages : "order_id"

  payments ||--o{ transactions : "payment_id"

  auth_user ||--o{ token_blacklist_outstandingtoken : "user_id"
  token_blacklist_outstandingtoken ||--|| token_blacklist_blacklistedtoken : "outstanding_token_id"
```

# ERD Explanation and Design Notes

This ERD models the database structure for the food ordering system.  
The design focuses only on information that needs to be stored permanently inside the database.

The schema is organized around the main flow of the application:

```text
Customer → Menu → Cart → Order → Payment → Tracking → Notifications
```

Each table is responsible for storing a specific part of that process.

---


## ACCOUNTS

This table stores customer identity and account information.

It is responsible for:
- registration
- login credentials
- account status
- contact information

Example stored data:
- email
- password hash
- phone number
- display name

This acts as the central user table of the system.

---

## MENU_CATALOGS

This table groups menu items into catalogs.

Examples:
- Breakfast Menu
- Dinner Menu
- Seasonal Menu

In a simple deployment, only one catalog may exist.  
However, keeping this table makes the system easier to expand later.

---

## CATEGORIES

This table stores the available food categories used to classify menu items.

Examples:
- Starters
- Main Course
- Desserts
- Drinks

Keeping categories in a dedicated table allows them to be managed independently without modifying menu items directly.

---

## MENU_ITEMS

This table stores the actual food products shown to customers.

Example items:
- Burger
- Pizza
- Pasta

Each item stores:
- name
- description
- price
- a reference to its category via `category_id`
- availability
- image URL

Each menu item belongs to one catalog and one category. This represents the live restaurant menu.

---

## CARTS

This table stores a customer's active shopping cart.

The cart acts as temporary storage before checkout.

It allows customers to:
- add items
- remove items
- update quantities
- prepare an order before payment

The system supports one active cart per customer.

---

## CART_ITEMS

This table stores the individual items inside a cart.

Each row represents:
- one selected menu item
- its quantity
- pricing information

Example:

| Cart | Item | Quantity |
|---|---|---|
| Cart #1 | Burger | 2 |

This table creates the relationship between carts and menu items.

---

## ORDERS

This table stores finalized customer purchases.

An order is created when checkout is completed.

The table stores:
- order status
- total amount
- delivery address
- timestamps
- customer reference

Unlike carts, orders are permanent business records.

---

## ORDER_ITEMS

This table stores the items that belong to a completed order.

It is separated from `CART_ITEMS` because:
- cart contents may change
- completed orders must remain historically accurate

Snapshot fields are stored here so old orders do not change if:
- menu prices change
- item names change
- descriptions are updated later

This is important for consistency and auditing.

---

## PAYMENTS

This table stores payment attempts and payment state information.

It includes:
- payment method
- payment status
- amount
- processing timestamps

The system may store multiple payment attempts for the same order if:
- retries occur
- a payment initially fails

---

## TRANSACTIONS

This table stores transaction data returned from external payment providers.

Examples:
- Stripe
- PayPal
- Fawry

Stored information may include:
- authorization codes
- gateway references
- processing timestamps

This table improves:
- payment auditing
- debugging
- retry handling

---

## ORDER_STATUS_HISTORY

This table stores the history of order status changes.

Instead of storing only the current status, the system keeps a timeline of updates.

Example timeline:

| Time | Status |
|---|---|
| 7:00 PM | PENDING |
| 7:05 PM | PREPARING |
| 7:20 PM | OUT_FOR_DELIVERY |

This supports:
- order tracking
- customer transparency
- delivery progress history

---

## NOTIFICATION_MESSAGES

This table stores notifications sent to customers.

Examples:
- order confirmation emails
- payment confirmations
- delivery updates

The system can track:
- message content
- delivery status
- send timestamps

This improves reliability and customer communication.

---

## TOKEN_BLACKLIST_OUTSTANDINGTOKEN

This table is created and managed automatically by the `djangorestframework-simplejwt` library.

It stores a record of every JWT token that has been issued by the system.

Each row stores:
- a unique token identifier (`jti`)
- the full token string
- the token's creation and expiry timestamps

This table is not written to by application code directly. simplejwt populates it automatically when a token is generated during login or registration.

Note: the `user_id` column exists because simplejwt was designed to work with Django's built-in user model. Since this system uses a custom `accounts` table instead, `user_id` is always stored as null and has no effect on functionality.

---

## TOKEN_BLACKLIST_BLACKLISTEDTOKEN

This table is created and managed automatically by the `djangorestframework-simplejwt` library.

It stores a record of every token that has been explicitly invalidated.

A token is added to this table when a customer logs out. Once a token appears here, it can never be used again — even if it has not yet expired.

Each row stores:
- a reference to the token in `token_blacklist_outstandingtoken`
- the timestamp when the token was blacklisted

This table works together with `token_blacklist_outstandingtoken` to implement server-side logout. On every authenticated request, simplejwt checks whether the incoming token's `jti` exists in this table. If it does, the request is rejected immediately.

---

# Relationship Explanation

The relationships in the ERD describe how data connects together.

## Customer Relationships

A customer can:
- place many orders
- receive many notifications

However, each customer has only one active cart.

---

## Cart Relationships

A cart contains many cart items.

Each cart item references exactly one menu item.

This allows customers to select multiple products and quantities before checkout.

---

## Menu Relationships

Each menu item belongs to one catalog and one category.

A catalog can contain many menu items.  
A category can contain many menu items.

This separation allows the menu to be organized and filtered independently by catalog or category.

---

## Order Relationships

An order contains:
- many order items
- many status history records

This supports:
- multi-item purchases
- detailed order tracking

---

## Payment Relationships

An order may contain multiple payment attempts.

This allows the system to preserve:
- failed payments
- retries
- recovery attempts

A payment may also contain multiple transactions if the payment gateway separates:
- authorization
- capture
- settlement

---

# Constraints and Data Integrity

The schema includes rules to keep stored data valid and consistent.

---

## Unique Constraints

Some values must always be unique.

Examples:
- email addresses
- order IDs
- payment IDs

This prevents duplicate records.

---

## NOT NULL Constraints

Important fields should never be empty.

Examples:
- email
- password hash
- item name
- payment amount

This ensures required business data always exists.

---

## Numeric Validation

Numeric values should be restricted to valid ranges.

Examples:

```sql
quantity > 0
price >= 0
amount >= 0
```

This prevents invalid business data such as:
- negative prices
- zero quantities

---

## Indexing

Indexes improve database query performance.

Examples:
- searching menu items by catalog or category
- loading order history
- tracking order status changes

Without indexes, large databases become slower over time.
