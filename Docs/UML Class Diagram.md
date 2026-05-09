# UML Class Diagram

This diagram models the customer-ordering-system as a domain-first design derived from the requirements and use cases in this repository.

## Class Diagram

```mermaid
classDiagram
direction LR

class CustomerAccount {
  +String accountId
  +String displayName
  +String email
  +String passwordHash
  +String phoneNumber
  +Boolean active
  +register()
  +authenticate()
}

class Session {
  +String sessionId
  +DateTime createdAt
  +DateTime expiresAt
  +Boolean active
  +invalidate()
}

class AuthenticationService {
  +registerCustomer()
  +login()
  +logout()
  +refreshSession()
}

class MenuCatalog {
  +String catalogId
  +listItems()
  +searchItems()
  +filterItems()
  +sortItems()
}

class MenuItem {
  +String menuItemId
  +String name
  +String description
  +Decimal price
  +String category
  +Boolean available
}

class MenuService {
  +getCatalog()
  +getMenuItem()
  +searchMenu()
}

class Cart {
  +String cartId
  +DateTime createdAt
  +DateTime updatedAt
  +addItem()
  +updateQuantity()
  +removeItem()
  +calculateTotal()
  +clear()
}

class CartItem {
  +String cartItemId
  +int quantity
  +Decimal unitPrice
  +Decimal lineTotal
}

class CartService {
  +getCart()
  +addItemToCart()
  +updateCartItem()
  +removeCartItem()
  +validateQuantity()
}

class Order {
  +String orderId
  +DateTime createdAt
  +Decimal totalAmount
  +OrderStatus status
  +place()
  +markPaid()
  +markConfirmed()
  +markFailed()
}

class OrderItem {
  +String orderItemId
  +int quantity
  +Decimal unitPrice
  +Decimal lineTotal
}

class OrderService {
  +createOrder()
  +validateCart()
  +repriceOrder()
  +cancelOrder()
}

class OrderStatusHistory {
  +String historyId
  +OrderStatus status
  +DateTime changedAt
  +String note
}

class OrderTrackingService {
  +getOrderStatus()
  +getStatusHistory()
}

class PaymentMethod {
  <<enumeration>>
  CARD
  DIGITAL_WALLET
  BANK_TRANSFER
  CASH_ON_DELIVERY
}

class Payment {
  +String paymentId
  +PaymentMethod method
  +Decimal amount
  +PaymentStatus status
  +String transactionId
  +authorize()
  +capture()
  +fail()
}

class Transaction {
  +String transactionId
  +String gatewayReference
  +DateTime processedAt
  +String authorizationCode
}

class PaymentService {
  +choosePaymentMethod()
  +processPayment()
  +retryPayment()
  +recordTransaction()
}

class PaymentGatewayAdapter {
  +authorizePayment()
  +capturePayment()
  +handleTimeout()
}

class NotificationMessage {
  +String messageId
  +String subject
  +String body
  +DateTime createdAt
}

class NotificationService {
  +sendConfirmation()
  +retryDelivery()
  +storeInNotificationCenter()
}

class OrderStatus {
  <<enumeration>>
  PENDING
  PAID
  CONFIRMED
  PAYMENT_FAILED
  PREPARING
  READY
  OUT_FOR_DELIVERY
  DELIVERED
}

class PaymentStatus {
  <<enumeration>>
  INITIATED
  AUTHORIZED
  CAPTURED
  FAILED
}

CustomerAccount "1" o-- "0..1" Session : owns
CustomerAccount "1" o-- "1" Cart : has
CustomerAccount "1" o-- "0..*" Order : places

MenuCatalog "1" o-- "0..*" MenuItem : contains
Cart "1" *-- "1..*" CartItem : contains
CartItem "*" --> "1" MenuItem : references

Order "1" *-- "1..*" OrderItem : contains
OrderItem "*" --> "1" MenuItem : references
Order "1" o-- "0..1" Payment : paid by
Order "1" *-- "0..*" OrderStatusHistory : status changes
Payment "1" o-- "0..1" Transaction : records
Payment "1" --> "1" PaymentMethod : uses

AuthenticationService --> CustomerAccount : manages
AuthenticationService --> Session : creates
MenuService --> MenuCatalog : queries
CartService --> Cart : updates
CartService --> MenuItem : validates stock
OrderService --> Order : creates
OrderService --> Cart : converts
PaymentService --> Payment : processes
PaymentService --> PaymentGatewayAdapter : delegates
PaymentService --> Transaction : records
NotificationService --> NotificationMessage : builds
NotificationService --> CustomerAccount : delivers to
OrderTrackingService --> Order : reads
OrderTrackingService --> OrderStatusHistory : reads

Order ..> OrderStatus : uses
Payment ..> PaymentStatus : uses
AuthenticationService ..> CustomerAccount : secure login
PaymentService ..> PaymentMethod : selected method
```

## Why These Components

The model keeps the domain responsibilities separated so each functional requirement has a clear owner:

- FR1 and UC1 are handled by `CustomerAccount`, `Session`, and `AuthenticationService`.
- FR2 and UC2 are handled by `MenuCatalog`, `MenuItem`, and `MenuService`.
- FR3 and UC3 are handled by `Cart`, `CartItem`, and `CartService`.
- FR4 and UC4 are handled by `Order`, `OrderItem`, and `OrderService`.
- FR5 and UC5 are handled by `PaymentMethod`, `Payment`, `Transaction`, `PaymentService`, and `PaymentGatewayAdapter`.
- FR6 is represented by the payment processing collaboration between `PaymentService` and `PaymentGatewayAdapter`.
- FR7 and UC6 are handled by `NotificationMessage` and `NotificationService`.
- FR8 is handled by `OrderStatusHistory`, `OrderStatus`, and `OrderTrackingService`.
- FR9 and UC7 are handled by `OrderTrackingService` reading the order and its status history.

## Traceability Summary

| FR / UC | Main Classes and Services |
| --- | --- |
| FR1 / UC1 | CustomerAccount, Session, AuthenticationService |
| FR2 / UC2 | MenuCatalog, MenuItem, MenuService |
| FR3 / UC3 | Cart, CartItem, CartService |
| FR4 / UC4 | Order, OrderItem, OrderService |
| FR5 / UC5 | PaymentMethod, Payment, Transaction, PaymentService, PaymentGatewayAdapter |
| FR6 / UC5 | PaymentService, PaymentGatewayAdapter, Transaction |
| FR7 / UC6 | NotificationMessage, NotificationService, Order |
| FR8 / UC7 | OrderStatus, OrderStatusHistory, OrderTrackingService |
| FR9 / UC7 | OrderTrackingService, OrderStatusHistory, Order |

## Design Notes

- `CustomerAccount` owns authentication identity data, but session lifecycle is separate in `Session` so login and timeout behavior are explicit.
- `Cart` and `Order` both contain line items, but `CartItem` and `OrderItem` are separate because cart pricing and finalized order pricing should not be conflated.
- `PaymentGatewayAdapter` isolates the external gateway integration so retries, timeout handling, and gateway changes do not leak into the domain model.
- `OrderStatusHistory` is included because UC7 requires status tracking and UC6/FR8 require status updates over time, not just a single current state.
- NFR3 is reflected by secure authentication and payment coordination, while NFR1 and NFR2 are operational constraints rather than standalone classes.
```
