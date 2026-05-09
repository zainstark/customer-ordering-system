# Requirements
### FR1
Customer can register/login
### FR2
Customer can browse menu
### FR3
Customer can add items to cart
### FR4
Customer can place order
### FR5
Customer can choose payment method
### FR6
System processes payment
### FR7
System sends order confirmation
### FR8
Update order status
### FR9
Customer tracks order

### NFR1
Response time ≤ 2 seconds
### NFR2
Payment success rate ≥ 99.5%
### NFR3
Secure transactions using HTTPS


## Traceability Map
| FR \ UC             | UC1 Auth | UC2 Browse | UC3 Cart | UC4 Order | UC5 Payment | UC6 Confirm | UC7 Track |
| ------------------- | -------- | ---------- | -------- | --------- | ----------- | ----------- | --------- |
| FR1 Login           | 1.0      | 0          | 0        | 0         | 0           | 0           | 0         |
| FR2 Browse          | 0        | 1.0        | 0.3      | 0         | 0           | 0           | 0         |
| FR3 Add to cart     | 0        | 0.3        | 1.0      | 0.5       | 0           | 0           | 0         |
| FR4 Place order     | 0        | 0          | 0.5      | 1.0       | 0.5         | 0           | 0         |
| FR5 Choose payment  | 0        | 0          | 0        | 0.3       | 1.0         | 0           | 0         |
| FR6 Process payment | 0        | 0          | 0        | 0.3       | 1.0         | 0.5         | 0         |
| FR7 Confirmation    | 0        | 0          | 0        | 0         | 0.5         | 1.0         | 0         |
| FR8 Update status   | 0        | 0          | 0        | 0         | 0           | 0.5         | 1.0       |
| FR9 Track order     | 0        | 0          | 0        | 0         | 0           | 0           | 1.0       |



## UC1 – Authentication

| Element                   | Description                                                                                                                                                                                                                                                        |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Actor**                 | Customer                                                                                                                                                                                                                                                           |
| **Preconditions**         | None (customer is not logged in)                                                                                                                                                                                                                                   |
| **Postconditions**        | Customer is successfully logged in and has a valid session.                                                                                                                                                                                                        |
| **Main Success Scenario** | 1. Customer provides email/username and password.<br>2. System validates credentials.<br>3. System creates a secure session (HTTPS – NFR3).<br>4. System responds within ≤2 seconds (NFR1).<br>5. Customer is granted access to browse, cart, and order functions. |
| **Alternative Flows**     | *Registration*: If customer has no account, system allows registration (new credentials stored securely).<br>*Invalid credentials*: System displays error and prompts retry.<br>*Timeout*: Session expires after inactivity; customer must re-authenticate.        |

---

## UC2 – Browse Menu

| Element | Description |
|---------|-------------|
| **Actor** | Customer |
| **Preconditions** | Customer is authenticated (UC1). |
| **Postconditions** | Customer views available menu items with details (name, price, description). |
| **Main Success Scenario** | 1. Customer requests menu view.<br>2. System retrieves menu data from database.<br>3. System displays menu items within ≤2 seconds (NFR1).<br>4. Customer can filter/search/sort items. |
| **Alternative Flows** | *Empty menu*: System shows "No items available".<br>*Data load failure*: System retries twice, then shows error message. |

---

## UC3 – Manage Cart

| Element | Description |
|---------|-------------|
| **Actor** | Customer |
| **Preconditions** | Customer is authenticated. Menu items are visible (UC2). |
| **Postconditions** | Cart reflects the customer’s selected items with quantities and running total. |
| **Main Success Scenario** | 1. Customer adds an item to cart (with quantity).<br>2. System updates cart contents and recalculates total.<br>3. System responds within ≤2 seconds (NFR1).<br>4. Customer can view cart, modify quantities, or remove items. |
| **Alternative Flows** | *Item out of stock*: System notifies customer and prevents addition.<br>*Invalid quantity*: System rejects negative/zero values and shows error. |

---

## UC4 – Place Order

| Element | Description |
|---------|-------------|
| **Actor** | Customer |
| **Preconditions** | Cart is not empty (UC3). Customer is authenticated. |
| **Postconditions** | Order is created with a unique ID, status = "Pending", and payment is initiated. |
| **Main Success Scenario** | 1. Customer confirms cart and clicks "Place Order".<br>2. System validates cart items (availability, pricing).<br>3. System creates order record and assigns an order ID.<br>4. System responds within ≤2 seconds (NFR1).<br>5. System transitions to UC5 (Process Payment). |
| **Alternative Flows** | *Cart empty*: System prevents order placement with message.<br>*Item price changed*: System notifies customer, updates cart, and requests confirmation.<br>*Item now unavailable*: System removes item and asks customer to revise order. |

---

## UC5 – Process Payment

| Element | Description |
|---------|-------------|
| **Actors** | Customer, External Payment Gateway |
| **Preconditions** | Order is created (UC4). Customer has chosen a payment method. |
| **Postconditions** | Payment is either successful (order status = "Paid") or failed (order status = "Payment Failed"). |
| **Main Success Scenario** | 1. Customer selects payment method (credit card, digital wallet, etc.).<br>2. System collects payment details securely over HTTPS (NFR3).<br>3. System communicates with external payment gateway.<br>4. Gateway authorizes the transaction.<br>5. System marks order as "Paid" and records transaction ID.<br>6. Success rate meets ≥99.5% target (NFR2). |
| **Alternative Flows** | *Insufficient funds / declined*: System notifies customer, allows retry or different method.<br>*Gateway timeout*: System retries up to 3 times; if still fails, order status = "Payment Failed" and customer is notified.<br>*Fraud detection*: Gateway blocks payment; system alerts customer to contact support. |

---

## UC6 – Send Confirmation

| Element | Description |
|---------|-------------|
| **Actor** | System (automated) |
| **Preconditions** | Payment is successful (UC5). |
| **Postconditions** | Customer receives order confirmation via email/SMS. Order status updated to "Confirmed". |
| **Main Success Scenario** | 1. System generates confirmation message (order ID, items, total, estimated time).<br>2. System sends message to customer’s registered contact.<br>3. System updates order status to "Confirmed".<br>4. All actions complete within ≤2 seconds of payment success (NFR1). |
| **Alternative Flows** | *Delivery failure*: System retries sending up to 3 times; logs error for manual review.<br>*Customer contact missing*: System stores confirmation in account notification center. |

---

## UC7 – Track Order

| Element | Description |
|---------|-------------|
| **Actor** | Customer |
| **Preconditions** | Order has been placed and confirmed (UC4 + UC6). |
| **Postconditions** | Customer sees real-time (or near-real-time) order status (e.g., Preparing, Ready, Out for Delivery, Delivered). |
| **Main Success Scenario** | 1. Customer requests order status using order ID.<br>2. System retrieves current status and timestamp.<br>3. System displays status within ≤2 seconds (NFR1).<br>4. System optionally shows history of status changes (UC8 – Update order status, implicitly included). |
| **Alternative Flows** | *Invalid order ID*: System shows error "Order not found".<br>*Status not yet updated*: System shows last known status and next expected update time. |

---
