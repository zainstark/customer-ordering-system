# Edge Case Analysis — Customer Order Service System 

## UC1 – Authentication

### EC-UC1-01: Brute-Force Login Lockout

**Edge Case:** Customer or attacker submits incorrect credentials repeatedly, triggering account lockout.

**User Story:**
As a system security component,
I want to lock an account after N consecutive failed attempts,
So that brute-force password attacks are mitigated.

**Gherkin Scenario:**
```gherkin
Given a registered account for "user@example.com"
When the customer submits invalid credentials 5 consecutive times within 10 minutes
Then the system should lock the account for 15 minutes
And display "Account temporarily locked. Try again later or reset your password."
And log the lockout event with IP address and timestamp
```

---

### EC-UC1-02: Login with Non-Existent Account (Enumeration Prevention)

**Edge Case:** Customer attempts to log in with an unregistered email address.

**User Story:**
As a system security component,
I want to return a generic error for unknown accounts,
So that attackers cannot enumerate registered emails.

**Gherkin Scenario:**
```gherkin
Given no account exists for "ghost@example.com"
When the customer attempts to log in with "ghost@example.com" and any password
Then the system should return "Invalid email or password"
And the response time should be consistent with a failed valid-account login (timing attack prevention)
```

---

### EC-UC1-03: Session Token Expiry During Active Use

**Edge Case:** The customer's session expires mid-use while they are on the platform.

**User Story:**
As a customer,
I want to be gracefully redirected to login when my session expires,
So that I am not confused by silent failures.

**Gherkin Scenario:**
```gherkin
Given the customer is logged in and their session has been idle for 30 minutes
When the customer attempts to navigate to the cart or place an order
Then the system should redirect the customer to the login page
And display "Your session has expired. Please log in again."
And preserve their cart state for restoration after login
```

---

### EC-UC1-04: SQL Injection via Login Fields

**Edge Case:** A malicious actor submits SQL injection payloads in the email or password fields.

**User Story:**
As a system security component,
I want all login inputs to be sanitized and parameterized,
So that injection attacks cannot compromise the database.

**Gherkin Scenario:**
```gherkin
Given the customer is on the login page
When the customer enters "' OR '1'='1'; --" in the email field and submits
Then the system should treat the input as a literal string, not executable code
And return "Invalid email or password" without granting access
And log the suspicious attempt with IP address for security review
```

---

### EC-UC1-05: Registration with a Duplicate Email

**Edge Case:** A new customer tries to register with an already-registered email address.

**User Story:**
As a customer,
I want to be notified if my email is already registered,
So that I can log in or reset my password instead.

**Gherkin Scenario:**
```gherkin
Given an account already exists for "existing@example.com"
When a new customer submits the registration form with "existing@example.com"
Then the system should display "An account with this email already exists."
And offer a "Login" or "Forgot Password" link
And not create a duplicate account
```

---

## UC2 – Browse Menu

### EC-UC2-01: Menu Data Retrieval Failure After Retries

**Edge Case:** The database is unreachable and all 2 automatic retries defined in UC2 are exhausted.

**User Story:**
As a customer,
I want a clear error message when the menu cannot be loaded,
So that I understand it is a system issue and not my account.

**Gherkin Scenario:**
```gherkin
Given the menu database is unreachable
When the customer navigates to the menu page
And the system has retried the database query 2 times without success
Then the system should display "Unable to load the menu at this time. Please try again later."
And not expose any raw database error messages to the customer
And log the failure with an error code and timestamp
```

---

### EC-UC2-02: Menu Loads Beyond 2-Second SLA (NFR1)

**Edge Case:** Menu retrieval exceeds the 2-second response time limit under high load.

**User Story:**
As a customer,
I want a loading indicator and a timeout message if the menu is slow,
So that I have feedback on what the system is doing.

**Gherkin Scenario:**
```gherkin
Given the customer navigates to the menu page
When the menu data request takes longer than 2 seconds to respond
Then the system should display a loading indicator within the first 500ms
And after 2 seconds, display "Menu is taking longer than expected. Please try again."
And log the slow query as a performance incident
```

---

### EC-UC2-03: Menu Loaded with Zero Items

**Edge Case:** The menu table is empty due to maintenance or a data migration.

**User Story:**
As a customer,
I want a friendly empty-state message when no menu items are available,
So that I am not confused by a blank or broken page.

**Gherkin Scenario:**
```gherkin
Given the menu database contains zero active items
When the customer navigates to the menu page
Then the system should display "No menu items are currently available. Please check back later."
And not display any empty table rows or broken UI elements
```

---

### EC-UC2-04: Unauthenticated Access to Menu (Precondition Enforcement)

**Edge Case:** A customer accesses the menu URL directly without a valid session.

**User Story:**
As a system,
I want to enforce authentication before allowing menu access,
So that all browsing and subsequent actions are tied to a valid session.

**Gherkin Scenario:**
```gherkin
Given the customer has no valid session token
When the customer navigates directly to the menu page via URL
Then the system should redirect the customer to the login page
And display "Please log in to browse the menu."
And after successful login, redirect the customer back to the menu
```

---

### EC-UC2-05: Search/Filter Returns No Matching Results

**Edge Case:** The customer's search query or filter combination matches no menu items.

**User Story:**
As a customer,
I want a helpful no-results message when my search yields nothing,
So that I can refine my search or browse all items.

**Gherkin Scenario:**
```gherkin
Given the customer is on the menu page
When the customer searches for a term that matches no menu items
Then the system should display "No items found. Try a different search or clear your filters."
And provide a "Clear Search" option to return to the full menu
```

---

## UC3 – Manage Cart

### EC-UC3-01: Adding an Out-of-Stock Item

**Edge Case:** A customer adds an item that became out of stock after the menu was loaded.

**User Story:**
As a customer,
I want to be informed immediately when an item I am adding goes out of stock,
So that I can choose an alternative before reaching checkout.

**Gherkin Scenario:**
```gherkin
Given "Chicken Burger" appears available on the menu page
And another order has depleted the last unit since the menu loaded
When the customer clicks "Add to Cart" for "Chicken Burger"
Then the system should display "Sorry, this item is currently out of stock."
And not add the item to the cart
And update the menu to mark the item as unavailable
```

---

### EC-UC3-02: Concurrent Cart Modification (Race Condition)

**Edge Case:** The same customer modifies the cart from two devices simultaneously, causing a conflict.

**User Story:**
As a system,
I want to handle concurrent cart updates safely,
So that the cart always reflects a consistent and deterministic state.

**Gherkin Scenario:**
```gherkin
Given the customer is logged in on Device A and Device B with the same cart
When Device A increases item quantity to 2 simultaneously as Device B removes the item
Then the system should apply one change atomically
And reflect the final resolved state on both devices
And not result in a negative quantity or corrupted cart record
```

---

### EC-UC3-03: Item Price Change While in Cart

**Edge Case:** An administrator updates an item's price after the customer has added it to their cart.

**User Story:**
As a customer,
I want to be alerted when a cart item's price changes before I check out,
So that I can make an informed decision before placing the order.

**Gherkin Scenario:**
```gherkin
Given the customer has "Steak x1" at £25.00 in their cart
And an administrator updates the price of "Steak" to £30.00
When the customer views their cart or proceeds to checkout
Then the system should display "The price of Steak has changed from £25.00 to £30.00."
And update the cart total to reflect the new price
And require the customer to confirm before continuing
```

---

### EC-UC3-04: Cart Persistence After Session Expiry

**Edge Case:** The customer's session expires before checkout; cart state is lost on re-login.

**User Story:**
As a customer,
I want my cart contents to be restored when I re-authenticate after a timeout,
So that I do not have to rebuild my cart from scratch.

**Gherkin Scenario:**
```gherkin
Given the customer has items in their cart and their session expires
When the customer logs in again
Then the system should restore the cart with the same items and quantities
And validate that all restored items are still available at the same price
And notify the customer of any items that are no longer available or have changed in price
```

---

### EC-UC3-05: Zero or Negative Quantity Input

**Edge Case:** The customer enters 0 or a negative number in the quantity field.

**User Story:**
As a customer,
I want the system to reject invalid quantities and prompt me for a valid value,
So that my cart always reflects a meaningful order.

**Gherkin Scenario:**
```gherkin
Given the customer is updating item quantity in the cart
When the customer sets the quantity to -1 or 0 and attempts to update
Then the system should display "Quantity must be at least 1."
And not update the cart with the invalid value
And reset the quantity field to the last valid value
```

---

## UC4 – Place Order

### EC-UC4-01: Empty Cart Bypass via Direct API Call

**Edge Case:** A customer bypasses UI controls and submits an order placement request with an empty cart via the API.

**User Story:**
As a system,
I want the server to independently validate that the cart is not empty,
So that empty orders cannot be created through client-side manipulation.

**Gherkin Scenario:**
```gherkin
Given the customer's cart is empty
When the customer sends a direct API request to POST /orders
Then the server should return HTTP 400 "Order cannot be placed with an empty cart."
And no order record should be created in the database
And the attempt should be logged as potential API abuse
```

---

### EC-UC4-02: Duplicate Order Submission (Double-Click / Network Retry)

**Edge Case:** The customer double-clicks "Place Order" or the browser retries the request, risking duplicate orders.

**User Story:**
As a system,
I want idempotency controls on the order placement endpoint,
So that multiple identical requests result in only one order being created.

**Gherkin Scenario:**
```gherkin
Given the customer clicks "Place Order" and the request is in-flight
When a second identical request is received (double-click or browser retry)
Then the system should process only the first request
And return the same order ID to the second request
And not create two separate order records
And disable the "Place Order" button immediately after the first click
```

---

### EC-UC4-03: Inventory Race Condition at Order Placement

**Edge Case:** Two customers attempt to order the last unit of an item at exactly the same time.

**User Story:**
As a system,
I want atomic inventory reservation to prevent overselling,
So that at most one customer receives an item when only one unit remains.

**Gherkin Scenario:**
```gherkin
Given only 1 unit of "Lobster Bisque" remains in stock
When Customer A and Customer B both submit orders for it at the same millisecond
Then the system should allocate the item to exactly one customer using a database lock
And the other customer should receive "Sorry, this item is no longer available. Please revise your order."
And the inventory count should never go below zero
```

---

### EC-UC4-04: Client-Side Price Tampering via API

**Edge Case:** A malicious customer modifies the item price in the API request payload before the order is created.

**User Story:**
As a system,
I want order totals to be calculated exclusively from server-side price data,
So that manipulated client-supplied prices are rejected entirely.

**Gherkin Scenario:**
```gherkin
Given a customer intercepts the order placement request and changes item price to £0.01
When the server receives the tampered payload
Then the server should discard the client-supplied price
And recalculate the order total using authoritative database prices
And flag the request as a potential fraud attempt in the audit log
```

---

### EC-UC4-05: Order Placement Database Write Failure

**Edge Case:** The database write to create the order record fails at the moment of order submission.

**User Story:**
As a customer,
I want a clear error message when order creation fails,
So that I know my order was not placed and I can retry safely.

**Gherkin Scenario:**
```gherkin
Given the customer has a valid, non-empty cart and clicks "Place Order"
When the database write to create the order record fails
Then the system should display "We were unable to create your order. Please try again."
And not initiate any payment process
And preserve the cart state so the customer can retry
And log the failure with full context
```

---

## UC5 – Process Payment

### EC-UC5-01: Payment Gateway Timeout with Retry Exhaustion

**Edge Case:** The gateway does not respond, and all 3 retries defined in UC5 are exhausted.

**User Story:**
As a customer,
I want to be notified clearly if payment cannot be completed after retries,
So that I know to try a different payment method.

**Gherkin Scenario:**
```gherkin
Given the customer has confirmed their order and selected a payment method
When the payment gateway fails to respond on all 3 retry attempts
Then the system should set order status to "Payment Failed"
And display "Payment could not be completed. Please try a different payment method."
And not charge the customer for any failed attempt
```

---

### EC-UC5-02: Payment Success but Order Status Update Fails

**Edge Case:** The gateway authorizes payment successfully, but the database write to set the order to "Paid" fails.

**User Story:**
As a system,
I want a reconciliation mechanism for payments where the status update fails,
So that a customer is never charged without their order being recorded as paid.

**Gherkin Scenario:**
```gherkin
Given a payment is authorized successfully by the gateway for Order "ORD-1002"
When the database write to set status "Paid" fails
Then the system should queue the status update for retry via a background job
And store the transaction ID in a payment audit log
And notify the customer "Payment received. Your confirmation will follow shortly."
And raise an alert for manual reconciliation if the retry also fails
```

---

### EC-UC5-03: Duplicate Payment Submission (Double Charge Risk)

**Edge Case:** The same payment is submitted twice due to a network retry, risking a double charge.

**User Story:**
As a system,
I want to use idempotency keys with the payment gateway,
So that retried payment requests never result in the customer being charged twice.

**Gherkin Scenario:**
```gherkin
Given a payment request for Order "ORD-1001" times out before a response is received
When the system retries the payment request for "ORD-1001"
Then the system should include a unique idempotency key tied to the order ID
And the gateway should recognise the duplicate and return the original transaction result
And the customer should be charged only once
```

---

### EC-UC5-04: Payment Over HTTP Instead of HTTPS (NFR3 Violation)

**Edge Case:** A misconfiguration results in payment details being submitted over unencrypted HTTP.

**User Story:**
As a system security component,
I want all payment submissions to be strictly enforced over HTTPS,
So that payment data is never transmitted unencrypted.

**Gherkin Scenario:**
```gherkin
Given the server enforces HTTPS for all payment endpoints
When a payment request is made over plain HTTP
Then the server should reject the request (HTTP 301 redirect or 403 Forbidden)
And not process any payment details from the insecure request
And log the incident as a security violation
```

---

### EC-UC5-05: Payment Initiated for an Already-Paid Order

**Edge Case:** A race condition or UI bug submits a second payment request for an order already in "Paid" status.

**User Story:**
As a system,
I want to prevent processing a second payment for an already-paid order,
So that customers are never double-charged.

**Gherkin Scenario:**
```gherkin
Given Order "ORD-1003" already has status "Paid" with a recorded transaction ID
When a second payment request is received for Order "ORD-1003"
Then the system should detect the "Paid" status and return "This order has already been paid."
And not submit any request to the payment gateway
And log the duplicate payment attempt for audit
```

---

## UC6 – Send Confirmation

### EC-UC6-01: Confirmation Email Fails After All Retries

**Edge Case:** The notification service fails to deliver the email after exhausting all 3 retries.

**User Story:**
As a customer,
I want my confirmation accessible in-app even if email delivery fails,
So that I always have access to my order details.

**Gherkin Scenario:**
```gherkin
Given payment is successfully processed for Order "ORD-2001"
When the system fails to send the confirmation email after 3 retry attempts
Then the system should store the confirmation in the customer's in-app notification center
And log the delivery failure for manual review
And still update the order status to "Confirmed"
```

---

### EC-UC6-02: Duplicate Confirmation Messages Sent

**Edge Case:** A retry mechanism bug causes the confirmation to be sent multiple times for the same order.

**User Story:**
As a system,
I want confirmation dispatch to be idempotent,
So that the same confirmation is never delivered more than once per order.

**Gherkin Scenario:**
```gherkin
Given a confirmation for Order "ORD-2002" was successfully sent on the first attempt
When the retry job fires again for the same order due to a false negative
Then the system should detect that a confirmation was already delivered for "ORD-2002"
And skip the resend
And log the suppressed duplicate attempt
```

---

### EC-UC6-03: Confirmation Sent for a Subsequently Reversed Payment

**Edge Case:** A chargeback or reversal is triggered by the bank after the confirmation has already been sent.

**User Story:**
As a system,
I want to handle payment reversals by updating order status and notifying the customer,
So that a confirmed order is not prepared or dispatched after a reversal.

**Gherkin Scenario:**
```gherkin
Given a confirmation has been sent for Order "ORD-2003" with status "Confirmed"
When the payment gateway sends a chargeback or reversal webhook for the same order
Then the system should update the order status to "Payment Reversed"
And send a follow-up notification to the customer explaining the reversal
And block the order from being prepared or dispatched
And flag the order for financial reconciliation
```

---

### EC-UC6-04: Confirmation Contains Incorrect Order Details

**Edge Case:** The confirmation message is generated with wrong item names, quantities, or totals due to a data retrieval bug.

**User Story:**
As a customer,
I want my confirmation to accurately reflect my actual order,
So that I can rely on it for tracking and dispute resolution.

**Gherkin Scenario:**
```gherkin
Given Order "ORD-2004" contains "Pasta x2 = £18.00"
When the confirmation is generated using stale or cached data with incorrect quantities
Then the system should validate the confirmation data against the live order record before sending
And the total in the confirmation must match the charged amount exactly
And any discrepancy should block the confirmation and trigger an alert
```

---

### EC-UC6-05: Notification Service Completely Unavailable

**Edge Case:** The email/SMS provider is fully down at the time of dispatch.

**User Story:**
As a system,
I want to queue confirmations when the notification service is unavailable,
So that confirmations are delivered once the service recovers without data loss.

**Gherkin Scenario:**
```gherkin
Given the notification service is returning HTTP 503
When payment is successfully completed and a confirmation should be dispatched
Then the system should enqueue the message in a durable message queue
And store the confirmation in the in-app notification center immediately as a fallback
And redeliver from the queue once the notification service recovers
```

---

## UC7 – Track Order

### EC-UC7-01: Tracking an Order Belonging to a Different Customer

**Edge Case:** A logged-in customer attempts to track an order ID belonging to another customer.

**User Story:**
As a system security component,
I want to enforce customer-level authorization on order tracking,
So that customers can only view their own orders.

**Gherkin Scenario:**
```gherkin
Given Customer A is authenticated and Order "ORD-3001" belongs to Customer B
When Customer A requests the tracking status of "ORD-3001"
Then the system should return "Order not found." (same response as a non-existent ID)
And not expose any details of Customer B's order
And log the unauthorized access attempt with both customer IDs
```

---

### EC-UC7-02: Invalid or Non-Existent Order ID

**Edge Case:** The customer submits an order ID that does not exist in the system.

**User Story:**
As a customer,
I want a clear error message when an order ID is not found,
So that I know to check my confirmation for the correct ID.

**Gherkin Scenario:**
```gherkin
Given the customer is on the order tracking page
When the customer searches for order ID "ORD-FAKE-999"
Then the system should display "Order not found. Please check your order ID and try again."
And not expose any system internals or stack traces
```

---

### EC-UC7-03: Invalid Backward Status Transition

**Edge Case:** The backend attempts to set an order status to a previously completed state (e.g., "Delivered" → "Preparing").

**User Story:**
As a system,
I want to enforce a forward-only order status state machine,
So that status transitions can never regress to a prior state.

**Gherkin Scenario:**
```gherkin
Given Order "ORD-3002" has status "Delivered"
When a backend process attempts to update the status to "Preparing"
Then the system should reject the transition with "Invalid status transition: cannot move from 'Delivered' to 'Preparing'."
And preserve the "Delivered" status unchanged
And log the invalid transition attempt for investigation
```

---

### EC-UC7-04: Order Stuck in "Pending" After Successful Payment

**Edge Case:** Payment succeeded but the order status never advanced past "Pending" due to a workflow failure.

**User Story:**
As a customer,
I want the system to detect and escalate orders stuck in "Pending" after payment,
So that my order moves to the kitchen queue without me needing to take action.

**Gherkin Scenario:**
```gherkin
Given Order "ORD-3003" has a recorded successful payment transaction
And the order has remained in "Pending" status for more than 5 minutes
When the customer tracks Order "ORD-3003"
Then the system should display "We are confirming your order. This may take a moment."
And a background reconciliation job should detect and escalate the anomaly
And trigger an admin alert for manual resolution
```

---

### EC-UC7-05: High-Frequency Polling Causing Server Load (Rate Limiting)

**Edge Case:** A customer or script polls the tracking endpoint excessively, degrading performance for others.

**User Story:**
As a system,
I want to rate-limit order tracking requests per customer session,
So that excessive polling cannot impact system performance.

**Gherkin Scenario:**
```gherkin
Given the customer is tracking an active order
When the customer's client sends more than 30 requests per minute to the tracking endpoint
Then the system should return HTTP 429 Too Many Requests for requests exceeding the limit
And include a "Retry-After" header indicating when the next request is permitted
And display "Updates refresh automatically. No need to reload."
```

