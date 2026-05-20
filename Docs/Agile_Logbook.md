# Edge Case Analysis — Customer Order Service System

This file reflects only edge cases that are implemented in the current system across `src/back` and `src/front`.

---

## UC1 – Authentication

### EC-UC1-01: Brute-Force Login Lockout

**Edge Case:** A customer submits incorrect credentials repeatedly and is temporarily locked out.

**Persona:**
> **Karim, 34 — Frustrated Returning Customer**
> Karim used the app months ago and can't remember which password variant he used. He tries his three most common passwords rapidly, one after another, without waiting between attempts. He is on mobile, so typos are common, and he doesn't notice the attempt counter climbing. He is not a malicious actor — just impatient — but his behavior is indistinguishable from a brute-force bot at the API level.
>
> *Why this persona uncovers the edge case:* Karim's rapid, repeated, well-intentioned attempts trigger the lockout threshold. He also highlights a hidden requirement: the lockout message must be human-friendly enough that a legitimate user understands what happened and is guided toward password reset rather than assuming a system error.

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

**Persona:**
> **Nour, 27 — Multi-Account User**
> Nour has accounts on many food-ordering platforms and mistakenly uses her work email to log in, not realising she originally registered with her personal Gmail. She is confused when the login fails, because she is certain she has used the system before. She tries several email variations before giving up.
>
> *Why this persona uncovers the edge case:* Nour's confusion reveals that the generic "Invalid email or password" response — while correct for security — creates friction for legitimate users. It surfaces a hidden requirement: the frontend should offer a "Forgot which email you used?" path or a registration prompt so that users like Nour are not silently lost.

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

**Persona:**
> **Salma, 41 — Distracted Multitasker**
> Salma opens the app during her lunch break, starts browsing the menu, then gets pulled into a meeting. An hour later she returns to her phone, resumes the app from background, and tries to add something to her cart. Her token has long since expired, but the app still looks fully loaded from her perspective.
>
> *Why this persona uncovers the edge case:* Salma never explicitly logs out, so from her point of view the session should still be valid. This highlights a hidden requirement: the app must handle 401/403 responses gracefully on any API call — not just the login screen — and must not lose the user's browsing state (e.g., selected items) when redirecting to re-authentication.

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

**Persona:**
> **Omar, 22 — Forgetful First-Timer**
> Omar registered an account six months ago, forgot about it entirely, and now thinks he is signing up for the first time. He completes the full registration form and is surprised when it fails. He does not associate the error with a previous account; he assumes the app is broken.
>
> *Why this persona uncovers the edge case:* Omar's experience exposes a hidden UX requirement: the "Email already in use" error should also offer a direct link to the login page and a password-reset option, so that users who have an existing account are converted rather than lost. Without this, the error is technically correct but practically unhelpful.

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

**Persona:**
> **Hana, 30 — Lunch-Rush Customer**
> Hana opens the app at 12:55 PM, five minutes before her lunch window closes. The backend is briefly unavailable due to a peak-load spike. She sees the menu page but it appears blank — no items, no spinner, no message — and she closes the app thinking it crashed.
>
> *Why this persona uncovers the edge case:* Hana's time pressure means she will not wait to retry; a silent failure costs a completed order. This reveals a hidden requirement: the error state must appear quickly (not after a long timeout), and the retry button must be prominently placed so that a user with seconds to spare can attempt recovery without navigating away.

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

**Persona:**
> **Tarek, 19 — Early-Morning User**
> Tarek opens the app at 6:00 AM, before the restaurant has configured its daily menu. The backend returns an empty category list. He stares at a blank page and assumes the app is broken or that his account has an issue.
>
> *Why this persona uncovers the edge case:* Tarek's experience highlights a hidden requirement: the empty-state message should also communicate *why* the menu is empty when that context is inferable (e.g., "Menu not available yet — check back later"), rather than simply stating that no items exist. A generic empty state without context drives user drop-off.

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

**Persona:**
> **Rana, 25 — Link-Sharing User**
> A friend sends Rana a deep-link to a specific menu page. Rana has never used the app before and has no account. She taps the link and expects to see the menu, but is instead redirected to login — with no explanation of why she cannot view the page she was invited to see.
>
> *Why this persona uncovers the edge case:* Rana's path exposes a hidden requirement: the login redirect should preserve the originally-requested deep-link so that after successful authentication, the app navigates back to it automatically. Without this, Rana authenticates and lands on a generic home screen, and may never find the page she originally wanted.

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

**Persona:**
> **Layla, 28 — Peak-Hour Shopper**
> Layla browses the menu during the dinner rush. She spots a popular item, spends two minutes deciding, then taps "Add to Cart." In that window, the item sold out and was deactivated on the backend. The frontend still shows it as available because her menu page was not refreshed.
>
> *Why this persona uncovers the edge case:* Layla's scenario uncovers a hidden requirement: the frontend must handle the out-of-stock rejection gracefully, updating the displayed item's status in real time or at the point of add-to-cart, so that the user receives immediate, contextual feedback rather than a generic error.

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

**Persona:**
> **Ahmed, 35 — Budget-Conscious Planner**
> Ahmed adds items to his cart early in the day intending to order at lunch. The restaurant updates its prices mid-morning. When Ahmed proceeds to checkout, the total no longer matches what he expected based on the cart summary he saw earlier.
>
> *Why this persona uncovers the edge case:* Ahmed's experience reveals a hidden requirement: when a price-change issue is flagged during validation, the system must clearly communicate *which* item changed and by how much, so the user can make an informed decision about whether to proceed. A generic "cart invalid" message without specifics creates distrust.

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

**Persona:**
> **Dina, 32 — Interrupted Shopper**
> Dina adds several items to her cart, gets a phone call, and the app logs her out after an idle timeout. She logs back in expecting to find her cart intact, but is worried her selections are gone. She checks the cart immediately on login.
>
> *Why this persona uncovers the edge case:* Dina's scenario surfaces a hidden requirement: the app should proactively show a cart-restoration confirmation or badge on re-login, so users are immediately reassured their items persisted. Silently restoring the cart without any indication may cause users like Dina to rebuild it unnecessarily, resulting in duplicate items if the restoration also succeeded.

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

**Persona:**
> **Youssef, 21 — Mobile User with Fat-Finger Input**
> Youssef tries to reduce the quantity of an item from 2 to 1 by tapping the decrement button rapidly. Due to a UI lag, he taps one too many times, bringing the value to 0. He does not notice and proceeds toward checkout.
>
> *Why this persona uncovers the edge case:* Youssef's behavior highlights a hidden requirement: the decrement button should be disabled (or convert to a "Remove" action) when the quantity reaches 1, preventing the zero-quantity state from being reachable through normal UI interaction. The server-side rejection is a necessary safety net, but the frontend guard is what makes the experience coherent.

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

**Persona:**
> **Ziad, 24 — Developer Testing His Own Account**
> Ziad is a CS student who notices the app uses a REST API. Out of curiosity, he inspects the network traffic, copies the place-order endpoint, and sends a raw request with an empty cart using a tool like Postman. He is not attempting fraud — he is exploring the system — but his request bypasses all frontend guards.
>
> *Why this persona uncovers the edge case:* Ziad's behaviour is realistic for a technically-literate user base and confirms that client-side cart validation alone is insufficient. The hidden requirement exposed here is that the server must enforce all business rules independently of what the frontend sends, treating every incoming API call as potentially unvetted.

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

**Persona:**
> **Mona, 38 — Slow-Connection User**
> Mona places her order on a weak mobile data connection. The confirmation screen takes several seconds to appear. Unsure whether her tap registered, she taps "Place Order" a second time. Both requests reach the server within the 30-second window.
>
> *Why this persona uncovers the edge case:* Mona's scenario is extremely common on mobile networks and is not malicious. The hidden requirement it exposes is that the idempotency response must return the *same* order object (not just reject the duplicate), and the frontend must handle this gracefully — showing the original confirmation rather than an error — so that Mona has confidence her order went through exactly once.

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

**Persona:**
> **Khaled, 26 — Price-Aware Power User**
> Khaled intercepts his app's API traffic using a proxy tool and modifies the cart payload to reflect a lower price before submitting the order. He is deliberately attempting to pay less than the correct amount.
>
> *Why this persona uncovers the edge case:* Khaled represents an adversarial but realistic threat. His behaviour confirms that the server must never trust the price values submitted by the client. The hidden requirement exposed is that order creation must re-fetch live prices from the menu service at the moment of order, and the final receipt must reflect only server-calculated totals — making any client-side price manipulation completely ineffective.

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

**Persona:**
> **Sara, 29 — Network-Drop Victim**
> Sara completes the payment form and taps "Pay." Her connection drops just after the request is sent but before the response arrives. The app shows a timeout error and offers a retry button. She taps it, not knowing whether the first payment attempt reached the gateway.
>
> *Why this persona uncovers the edge case:* Sara's situation is a textbook network-reliability scenario. The hidden requirement it exposes is that the idempotency key must be generated and stored *before* the first attempt — not on each retry — so that both Sara's original request and her retry carry the same key. If the key is regenerated on each attempt, the protection collapses.

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

**Persona:**
> **Hassan, 45 — Tab-Duplicating User**
> Hassan opens the app on both his phone and his tablet. He places and pays for an order on his phone. A few minutes later he opens the same order on his tablet, sees the payment screen still loaded from before, and taps "Pay" — not realising the phone already completed it.
>
> *Why this persona uncovers the edge case:* Hassan's multi-device usage is entirely normal. His scenario exposes a hidden requirement: the payment screen must always check the current order status before presenting the payment option, and must refresh this status when the app returns to foreground. Relying on a cached view of the order is insufficient and can lead to real double-charge attempts.

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

**Persona:**
> **Lina, 33 — Notification-Sensitive User**
> Lina has strict notification habits and mutes apps that spam her. A background job re-processes order statuses during a system reconciliation run and triggers the notification logic for all orders, including ones already at their current status. Lina receives three identical "Your order is being prepared" messages within minutes.
>
> *Why this persona uncovers the edge case:* Lina's reaction — muting the app — represents a real and measurable business cost of duplicate notifications. Her scenario reveals a hidden requirement: the notification deduplication check must be atomic and consistent, protecting against concurrent or batch job triggers, not just sequential single-event triggers.

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

**Persona:**
> **Tamer, 31 — Curious Technologist**
> Tamer notices that order tracking URLs or API calls include a numeric order ID. He increments the ID by one to see what happens, hoping to view a real order from another customer out of curiosity rather than malicious intent.
>
> *Why this persona uncovers the edge case:* Tamer's behaviour — known as IDOR (Insecure Direct Object Reference) probing — is one of the most common API vulnerabilities. The hidden requirement it exposes is that the "Order not found" response must be indistinguishable from a genuinely non-existent order ID, so that enumeration attacks cannot confirm the existence of orders belonging to other users.

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

**Persona:**
> **Amira, 27 — Copy-Paste Error User**
> Amira receives an order confirmation via email and copies the order reference to paste into the tracking page. She accidentally copies one extra character at the end, making the ID invalid. The tracking page spins indefinitely before crashing, giving her no useful feedback.
>
> *Why this persona uncovers the edge case:* Amira's copy-paste error is a mundane but frequent occurrence. Her experience exposes a hidden requirement: the frontend must render the "Order not found" error state explicitly and quickly — without hanging on a loading spinner — and should offer Amira a clear path to her order history so she can locate the correct order without re-entering the ID manually.

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