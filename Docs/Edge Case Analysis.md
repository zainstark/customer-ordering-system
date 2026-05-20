# Edge Case Analysis — Customer Order Service System

This file reflects only edge cases that are implemented in the current system across `src/back` and `src/front`.

## UC1 – Authentication

### EC-UC1-01: Brute-Force Login Lockout

**Edge Case:** A customer submits incorrect credentials repeatedly and is temporarily locked out.

**User Story:**
As a system security component,
I want to lock an account after repeated failed login attempts,
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

### EC-UC1-02: Login with Non-Existent Account

**Edge Case:** A customer attempts to log in with an unregistered email address.

**User Story:**
As a system security component,
I want to return a generic error for unknown accounts,
So that unregistered emails are not treated differently in the response body.

**Gherkin Scenario:**
```gherkin
Given no account exists for "ghost@example.com"
When the customer attempts to log in with "ghost@example.com" and any password
Then the system should return "Invalid email or password"
And not authenticate the customer
```

---

### EC-UC1-03: Session Token Expiry During Active Use

**Edge Case:** The customer's token becomes invalid or expires while they are using the app.

**User Story:**
As a customer,
I want the app to end the invalid session and return me to login,
So that I can authenticate again and continue safely.

**Gherkin Scenario:**
```gherkin
Given the customer was previously authenticated
When a protected API call returns 401 or 403 because the token is invalid or expired
Then the app should clear the stored token
And redirect the customer to the login page
```

---

### EC-UC1-04: Registration with a Duplicate Email

**Edge Case:** A new customer tries to register with an email that already exists.

**User Story:**
As a customer,
I want to be notified if my email is already registered,
So that a duplicate account is not created.

**Gherkin Scenario:**
```gherkin
Given an account already exists for "existing@example.com"
When a new customer submits the registration form with "existing@example.com"
Then the system should reject the request
And return the validation message "Email already in use"
And not create a duplicate account
```

---

## UC2 – Browse Menu

### EC-UC2-01: Menu Data Retrieval Failure

**Edge Case:** The backend cannot load menu data.

**User Story:**
As a customer,
I want a clear error message when the menu cannot be loaded,
So that I understand the page failed instead of silently showing broken content.

**Gherkin Scenario:**
```gherkin
Given menu retrieval fails on the backend
When the customer navigates to the menu page
Then the API should return "Unable to load the menu at this time. Please try again later."
And the frontend should show an error state with a retry action
```

---

### EC-UC2-02: Menu Loaded with Zero Items

**Edge Case:** The menu contains no categories or items.

**User Story:**
As a customer,
I want a friendly empty-state message when no menu items are available,
So that I am not confused by a blank page.

**Gherkin Scenario:**
```gherkin
Given the menu backend returns zero categories
When the customer navigates to the menu page
Then the frontend should display "No menu items are currently available."
And provide a retry action
```

---

### EC-UC2-03: Unauthenticated Access to Menu

**Edge Case:** A customer attempts to open the menu without a valid authenticated session.

**User Story:**
As a system,
I want to enforce authentication before allowing menu access,
So that protected pages are only available to authenticated users.

**Gherkin Scenario:**
```gherkin
Given the customer is not authenticated
When the customer navigates to the menu route
Then the app should redirect the customer to the login page
And the backend should reject direct menu API access without authentication
```

---

## UC3 – Manage Cart

### EC-UC3-01: Adding an Out-of-Stock Item

**Edge Case:** A customer tries to add a menu item that is no longer available.

**User Story:**
As a customer,
I want unavailable items to be rejected when added to the cart,
So that my cart only contains orderable items.

**Gherkin Scenario:**
```gherkin
Given a menu item is no longer available in the backend
When the customer sends an add-to-cart request for that item
Then the system should reject the request
And return an out-of-stock error
And not add the item to the cart
```

---

### EC-UC3-02: Item Price Change While in Cart

**Edge Case:** A menu item's live price no longer matches the cart snapshot.

**User Story:**
As a system,
I want checkout validation to detect stale cart pricing,
So that the customer cannot continue with outdated totals.

**Gherkin Scenario:**
```gherkin
Given a cart item was saved with an older price snapshot
When cart validation runs before checkout
Then the system should mark the cart as invalid
And include a price-change issue in the validation response
```

---

### EC-UC3-03: Cart Persistence After Re-Authentication

**Edge Case:** A customer logs in again after the previous session is no longer valid.

**User Story:**
As a customer,
I want my cart to remain associated with my account after I sign in again,
So that I do not lose items that were already stored server-side.

**Gherkin Scenario:**
```gherkin
Given the customer already has items in a server-side cart
When the customer authenticates again with the same account
Then the cart endpoint should return the same saved cart items
```

---

### EC-UC3-04: Zero or Negative Quantity Input

**Edge Case:** A customer attempts to set cart quantity to zero or a negative value.

**User Story:**
As a system,
I want invalid quantities to be rejected,
So that the cart always contains positive quantities only.

**Gherkin Scenario:**
```gherkin
Given the customer is updating an item quantity
When the customer submits 0 or a negative number
Then the system should reject the request with a validation error
And not update the cart item
```

---

## UC4 – Place Order

### EC-UC4-01: Empty Cart Bypass via Direct API Call

**Edge Case:** A customer submits an order request while the cart is empty.

**User Story:**
As a system,
I want the server to validate that the cart is not empty,
So that empty orders cannot be created through client-side bypasses.

**Gherkin Scenario:**
```gherkin
Given the customer's cart is empty
When the customer sends a direct API request to place an order
Then the server should return "Cannot place an order with an empty cart."
And no order record should be created
```

---

### EC-UC4-02: Duplicate Order Submission

**Edge Case:** A customer submits the same order twice within a short period.

**User Story:**
As a system,
I want recent order placement to be idempotent,
So that duplicate submissions do not create duplicate orders.

**Gherkin Scenario:**
```gherkin
Given the customer has just placed an order
When a second order placement request is received within 30 seconds for the same account
Then the system should return the recent existing order
And not create a second order record
```

---

### EC-UC4-03: Client-Side Price Tampering via API

**Edge Case:** Cart snapshots or client assumptions do not match the live menu price at order time.

**User Story:**
As a system,
I want order totals to be calculated from live server-side menu prices,
So that the final order amount cannot be based on stale or manipulated client values.

**Gherkin Scenario:**
```gherkin
Given cart items exist for the customer
When the order is placed
Then the server should calculate the order total using live menu prices
And create order item snapshots from the current menu item data
```

---

## UC5 – Process Payment

### EC-UC5-01: Duplicate Payment Submission

**Edge Case:** The same payment flow is retried for the same order.

**User Story:**
As a system,
I want payment requests to use idempotency keys,
So that retries do not create duplicate payment intents unnecessarily.

**Gherkin Scenario:**
```gherkin
Given a payment session is being created or retried for an order
When the backend sends the request to the payment gateway
Then it should include an idempotency key derived from the order and payment attempt
```

---

### EC-UC5-02: Payment Initiated for an Already-Paid Order

**Edge Case:** A second payment request is attempted for an order that has already been paid.

**User Story:**
As a system,
I want to prevent processing another payment for an already-paid order,
So that customers are not charged twice.

**Gherkin Scenario:**
```gherkin
Given an order already has a completed payment
When another payment session is requested for that order
Then the system should reject the request
And return "Order is already paid."
```

---

## UC6 – Send Confirmation

### EC-UC6-01: Duplicate Status Notification Suppression

**Edge Case:** The backend attempts to notify the customer about an order status that did not actually change.

**User Story:**
As a system,
I want to suppress duplicate status notifications,
So that the customer does not receive repeated in-app messages for the same status.

**Gherkin Scenario:**
```gherkin
Given an order already has a known previous status
When notification logic is asked to notify the same status again
Then the system should not create a new in-app notification
```

---

## UC7 – Track Order

### EC-UC7-01: Tracking an Order Belonging to a Different Customer

**Edge Case:** A customer attempts to track an order that belongs to another account.

**User Story:**
As a system security component,
I want order tracking to be scoped to the authenticated account,
So that customers can only access their own orders.

**Gherkin Scenario:**
```gherkin
Given Customer A is authenticated
And the requested order belongs to Customer B
When Customer A requests the tracking endpoint
Then the system should return "Order not found."
And not expose the other customer's order details
```

---

### EC-UC7-02: Invalid or Non-Existent Order ID

**Edge Case:** A customer requests tracking for an order ID that does not exist.

**User Story:**
As a customer,
I want a clear not-found response when the order ID is invalid,
So that I know the requested order could not be located.

**Gherkin Scenario:**
```gherkin
Given the customer is on the order tracking page
When the customer requests a non-existent order ID
Then the backend should return "Order not found."
And the frontend should show an error state instead of crashing
```
