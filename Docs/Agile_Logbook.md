# Agile Logbook
### Customer Ordering System
---
## Sprint 1: Menu, Cart, and Order
---

## Part 1: Menu UX & Data Consistency (Flutter Frontend)

### 1. Specification (The Architect Bun)

**Functional Requirement:** Menu screens must be modular, reusable, and feature-first. Screens live in `presentation/screens`, reusable components in `presentation/widgets`, and the shared shell bar in `shell/presentation/widgets`.

**Functional Requirement:** Menu UI must reflect the implemented domain models (`MenuCategoryEntity`, `MenuItemEntity`) and support item-level browsing with a detail view, quantity selection, and an Add-to-Cart entry point wired to `CartCubit`.

**Non-Functional Requirement:** The app targets web first. Text must use `SelectableText` where appropriate. Layout must be responsive using `MediaQuery` breakpoints aligned with `app_dimensions.dart`. Theme tokens from `app_theme.dart` and `app_colors.dart` must be used consistently in both light and dark mode.

---

### 2. Implementation (The AI Meat)

#### Prompt 1 — Initial Screen Structure + Component Build

> **Role:** You are a senior Flutter UI engineer who builds scalable feature-first screens.  
> **Task:** Implement menu, cart, and orders presentation layers from the project's existing theme, dimension, and routing setup. Deliver `MenuScreen`, `CartScreen`, and `OrdersScreen` with their widget breakdowns — each screen in `presentation/screens`, each reusable piece in feature `presentation/widgets`.  
> **Context:** The project already has `app_theme.dart`, `app_colors.dart`, and `app_dimensions.dart`. The main router (`app_router.dart`) uses GoRouter with a `ShellRoute` for the shared navigation bar. The `Docs/` folder contains `ERD.md`, `UML Class Diagram.md`, and `Requirement and Use Cases.md` as structural references.  
> **Format:** Deliver a screen + widget breakdown per feature. Do not include backend logic or API calls — this phase is presentation only.  
> **Constraints & Examples:** Use `AppDimensions` constants for spacing and border radii. Use `Theme.of(context).colorScheme` for colors. Avoid hardcoded pixel values. Use a reusable item card widget for menu items rather than inline duplicated UI.

---

#### Prompt 2 — Feature Structure Enforcement

> **Role:** You are a Flutter architect enforcing project conventions and maintainable composition.  
> **Task:** Reorganize presentation code so screens are in `presentation/screens`, reusable feature widgets are in `presentation/widgets`, and the shared app shell bar is centralized in `shell/presentation/widgets/app_shell_scaffold.dart`.  
> **Context:** Some UI parts were duplicated or placed in the wrong layer. The shell scaffold (top bar, bottom navigation) must be shared across all routes via GoRouter's `ShellRoute`.  
> **Format:** Provide a short "before vs after" file-location summary.  
> **Constraints & Examples:** Preserve behavior and visual design. Only move files — do not rewrite widget logic. Do not touch `Core/` files.

---

#### Prompt 3 — Menu Cubit State + Category Interaction

> **Role:** You are a Flutter state-management engineer specializing in lightweight cubit interactions.  
> **Task:** Implement `MenuCubit` with dummy category data and a `selectCategory(String categoryId)` method. `MenuState` must hold a `List<MenuCategoryModel>` and a `selectedCategoryId`. `filteredDishes` must return the items for the selected category.  
> **Context:** At this stage the menu has no backend connection — it uses hardcoded `MenuCategoryModel` and `MenuItemModel` instances seeded directly in `MenuCubit`. The UI needs interactive category switching before full backend integration. `MenuCategoryModel` and `MenuItemModel` already exist in the data layer with `fromJson` constructors aligned to the backend schema.  
> **Format:** Show the cubit, state, and a brief description of the trigger → state update → rendered result flow.  
> **Constraints & Examples:** Keep state logic out of widgets. The cubit is registered as `registerFactory` in `injector.dart` so each route gets a fresh instance.

---

#### Prompt 4 — Menu UI Refinement + Item Detail Sheet

> **Role:** You are a product-focused Flutter engineer refining UI to match real data model capabilities.  
> **Task:** Remove placeholder UI elements not backed by `MenuItemEntity` fields (star ratings, generic icon-only cards). Align `MenuFoodCard` rendering with `title`, `description`, `price`, `available`, and `imageUrl`. Add `MenuItemDetailsSheet` — a `Dialog` that opens on item tap and shows the item image, title, price, category, availability, a quantity stepper, and an "Add to Cart" button.  
> **Context:** `MenuItemEntity` has: `id`, `categoryId`, `title`, `description`, `price`, `available`, `rating`, `imageUrl`. The `rating` field exists in the model but is not surfaced in the backend `Docs/ERD.md` — do not display it until the backend supports it. The "Add to Cart" button in the sheet will be wired to `CartCubit` in the Cart Integration sprint.  
> **Format:** Summarize removals, additions, and the final user interaction flow: item tap → sheet open → quantity adjust → Add to Cart.  
> **Constraints & Examples:** Do not fabricate data fields. `SelectableText` must be used for any text the user might want to copy on web.

---

#### Prompt 5 — Web-Oriented Text + Image Loading

> **Role:** You are a Flutter web UI engineer optimizing readability and media loading behavior.  
> **Task:** Replace static `Text` widgets in menu item cards and detail sheets with `SelectableText` for web usability. Implement `AppNetworkImage`, a shared widget that loads images from a URL with a consistent fallback placeholder (a container with a food icon) when the URL is missing or loading fails.  
> **Context:** The app targets web as its primary platform. Images come from `imageUrl` fields in `MenuItemEntity` and `CartItemEntity`. The fallback pattern must be consistent across menu cards, cart item cards, and order status cards.  
> **Format:** Provide a concise checklist of updated text behavior and the `AppNetworkImage` widget implementation.  
> **Constraints & Examples:** `AppNetworkImage` lives in `features/widgets/app_network_image.dart` as a shared cross-feature widget. Do not introduce multiple placeholder variants.

---

### 3. Verification & Audit (The Human Bun)

**Model-to-UI Consistency Check:**
- `MenuFoodCard` and `MenuItemDetailsSheet` render only fields present in `MenuItemEntity` and confirmed in `Docs/ERD.md`.
- Star ratings and unsupported decorative elements were removed.

**Component Structure Check:**
- Screens in `presentation/screens`, widgets in `presentation/widgets`, shell scaffold in `shell/presentation/widgets`.
- `AppNetworkImage` lives in the shared `features/widgets/` folder and is reused across menu, cart, and orders.

**UX Flow Check:**
- Category selection updates `selectedCategoryId` in `MenuState` and re-renders `filteredDishes`.
- Item tap opens `MenuItemDetailsSheet` with quantity control and an Add-to-Cart entry point.
- Widget tests in `test/features/menu/` cover cubit category switching, state filtering, and widget rendering.

---

### 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| Open menu screen | Categories and items render from `MenuCubit` dummy data | Pass |
| Select a menu category | `selectedCategoryId` updates; only that category's dishes appear | Pass |
| Tap menu item | `MenuItemDetailsSheet` opens with title, price, description, and quantity controls | Pass |
| Add to Cart button | Delegates to `CartCubit.addItem` (wired in Cart sprint) | Pass |
| Responsive breakpoints | Desktop shows sidebar + 3-column grid; tablet shows 2 columns; mobile shows 1 column | Pass |
| Selectable text on web | Item titles and descriptions are copyable | Pass |

---

## Part 2: Cart Feature Implementation (Django REST Framework Backend)

### 1. Specification (The Architect Bun)

**Functional Requirement (FR3):** The system shall allow an authenticated customer to add, update, remove, and view items in a persistent shopping cart, with a running total updated on every mutation.

**Functional Requirement (FR4):** The cart must be validatable before order placement — checking item availability, menu item existence, and price consistency against the live menu.

**Non-Functional Requirement (NFR 1 - Security):** All cart endpoints must be protected by JWT bearer token authentication. The account identity must be derived exclusively from the token payload — never from request body or query parameters. Cross-account cart item access must return `404 Not Found` (not `403`) to prevent resource enumeration.

**Non-Functional Requirement (NFR 2 - Integrity):** Item quantities must never fall below 1. `line_total` and `cartTotal` must be computed server-side from stored price snapshots, never from client-supplied values. `clear_cart` must execute atomically.

**Non-Functional Requirement (NFR 3 - Testability):** The menu lookup must be injectable via a provider seam (`CartService.set_menu_provider()`) so the service layer can be unit-tested without a populated `MenuItem` table.

**Data Privacy:** Prices are stored and computed in pennies internally. The `unit_price_snapshot` raw integer is never exposed to clients — all monetary values are returned as dollar floats. No PII flows through any service method.

---

### 2. Implementation (The AI Meat)

#### Prompt 1 — Feature Planning & Structure

> I have made a new folder called `cart` in the `apps` directory. This folder should contain what is needed to implement the Django backend for the Cart feature. Make a solid plan on how to make it — I recommend making a file called `modules` (which will contain classes that come from the database), a file called `view` (that will contain the endpoints), and lastly a `services` file (that will contain the business logic and other service classes). You should also take note for using dummy data for now as the database is not populated yet.

---

#### Prompt 2 — Initial Implementation & Debugging

> Everything seems to be working at least with the dummy data. I feel like `modules.py` is useless — can't we just do it all in the files that Django is expecting, which is `models.py`? Moreover, can you do a quick cleanup and remove what seems useless (not the dummy data and tests). Furthermore, can you read the `api-contract.md` that I attached and check if it matches our endpoints for the cart service only. If not, generate a new `api-contract.md` with our real endpoints for the frontend to use.

---

#### Prompt 3 — API Contract Compliance & Cleanup

> Actually, can you use this file instead (`API_CONTRACT.md`) and try to make the `CartService` compliant with this contract? As well as the cleanup if possible in the plan. Make the plan first. You know what — make a plan to ditch the `API_CONTRACT`, and fall back to how the API worked previously. Remove any redundant comments, and I want the repo to work like how it was before the first `api_contract`. Also modify the README in the backend to have the actual usage of the feature.

---

#### Prompt 4 — Endpoint Sanity & URL Clarity

> How can I get a cart if I don't have an ID for it? Can you make sure that all the endpoints can be called in a sensible way? These are the current URLs — are these correct or not?
> ```
> GET  /api/cart/           → get_cart
> POST /api/cart/items/     → add_item_to_cart
> PATCH /api/cart/items/{id}/ → update_cart_item
> DELETE /api/cart/items/{id}/ → remove_item_from_cart
> POST /api/cart/validate/  → validate_cart
> DELETE /api/cart/         → clear_cart
> ```
> Put a URL for each endpoint — it should be compatible with the API contract — and modify the comments to actually reflect the real URLs.

---

#### Prompt 5 — Auth Integration & Flutter Compatibility

> Make a plan to update the cart to work with the current changes: use the current auth, take its models from `generated_models.py` (because this is what the database is expecting), and also make it usable with what the Flutter frontend is expecting. The tests with the dummy data should still work, and remember the only way to auth is the generated JWT token. Is the cart backend what Flutter is expecting? Did you use the new `generated_models.py` file for the cart models?

---

### 3. Verification & Audit (The Human Bun)

**Dependency Audit:**
- All imports are from Django stdlib, DRF, or the existing project dependency `rest_framework_simplejwt`. No new packages were introduced.
- `DUMMY_MENU_ITEMS` in `services.py` is a temporary in-memory fixture, confirmed to be bypassed once the real `MenuItem` table is populated.

**Security Check:**
- Verified `test_get_cart_uses_token_account_not_query_account`: passing `?account_id=other_account` in the query string still returns the token holder's cart — account identity is read only from the JWT.
- PATCH and DELETE item views perform an explicit ownership check (`cart.account_id != account_id`) before calling the service, returning `404` on mismatch — confirmed this matches EC-UC3-02 (enumeration prevention).
- `unit_price_snapshot` is excluded from the serializer `fields` list; clients cannot read or influence the internal penny value.

**Logic Fixes:**
- AI used `menu_item.get('imageUrl')` only, missing the DB-sourced key `image_url`. Fixed with: `menu_item.get('image_url') or menu_item.get('imageUrl') or ''`.
- AI placed `line_total` computation only in `get_cart_total()` instead of persisting it in `save()`. Corrected so `line_total` is stored on every `CartItem.save()`.
- AI returned `HTTP_403_FORBIDDEN` on cart ownership mismatch. Changed to `HTTP_404_NOT_FOUND` per the enumeration-prevention requirement.
- AI called `RefreshToken.for_user(django_user)` in tests — incompatible with the custom `Accounts` model. Replaced with `RefreshToken()` and manual claim injection (`account_id`, `email`, `role`, `display_name`).
- AI omitted `_ensure_accounts_table()` in test setup, causing `OperationalError: no such table: accounts` for the unmanaged auth model. Fixed by calling it inside `setUpClass` of each test case.
- Migration failed with `non-nullable field 'account'` error after models were updated. Resolved by deleting stale migrations and regenerating them cleanly.

---

### 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| `GET /api/cart/` without token | `401 Unauthorized` | |
| `GET /api/cart/` with valid token | `200 OK`, `accountId` matches token | |
| `GET /api/cart/` with `?account_id` of another user in query | Returns token holder's cart, not the other account's | |
| `POST /api/cart/items/` with `quantity=0` | `400 Bad Request`, validation error | |
| `POST /api/cart/items/` with unknown `menu_item_id` | `400`, `"Menu item … not found"` | |
| `POST /api/cart/items/` with unavailable item | `400`, `"… is out of stock"` | |
| `POST /api/cart/items/` success — response shape | Keys: `id`, `cartId`, `menuItemId`, `title`, `subtitle`, `unitPrice`, `quantity`, `imageUrl` | |
| `POST /api/cart/items/` — `unitPrice` for 1599-penny item | `15.99` (float) | |
| `PATCH /api/cart/items/{id}/` for item in another account's cart | `404 Not Found` | |
| `DELETE /api/cart/items/{id}/delete/` for item in another account's cart | `404 Not Found` | |
| `CartItem.save()` with `qty=3`, `unit_price_snapshot=500` | `line_total == 1500` | |
| Add same menu item to cart twice | Quantity accumulates, single `CartItem` row | |
| `validate_cart_items` — price changed since addition | `is_valid: false`, `"Price has changed"` in issues | |
| `validate_cart_items` — all items current | `is_valid: true`, `issues: []` | |

---

## Part 3: Cart Integration Alignment (Flutter Frontend)

### 1. Specification (The Architect Bun)

**Functional Requirement:** The Cart API integration must match `Docs/cart_API_CONTRACT.md` exactly — endpoints, HTTP methods, request payloads, query parameters, and response field names.

**Functional Requirement:** Cart actions must be wired end-to-end: the "Add to Cart" button in `MenuItemDetailsSheet` must call `CartCubit.addItem`, and the trash icon in `CartItemCard` must call `CartCubit.removeItem`.

**Non-Functional Requirement:** No UI, widget, screen, or backend file may be modified. Only Cart data/domain layers and DI wiring are in scope.

---

### 2. Implementation (The AI Meat)

#### Prompt 1 — Contract-First Mismatch Analysis

> **Role:** You are a senior Flutter engineer with deep experience in Clean Architecture and API contract integration.  
> **Task:** Compare the current Cart implementation against `Docs/cart_API_CONTRACT.md`. List every mismatch before touching any code: wrong endpoints, wrong HTTP methods, wrong request body fields, wrong response field names, missing auth handling.  
> **Context:** The backend is already working. The cart contract defines these operations: `GET /api/cart/` (by `account_id` query param), `POST /api/cart/items/` (body: `account_id`, `menu_item_id`, `quantity`), `PATCH /api/cart/items/<cart_item_id>/` (body: `quantity`), `DELETE /api/cart/items/<cart_item_id>/delete/`. The response from the cart is a `Cart` object with nested `items`, each item having fields including `cart_item_id`, `menu_item_id`, `menu_item_name`, `menu_item_description`, `quantity`, `unit_price_snapshot`, and `line_total` in pennies.  
> **Format:** Return a mismatch report first (endpoint by endpoint), then list what files will change and why.  
> **Constraints & Examples:** The `DioClient` already handles bearer auth in its interceptor — datasources must not add their own auth headers. Reference `ERD.md` and `UML Class Diagram.md` from `Docs/` as supporting context for the data model.

---

#### Prompt 2 — API Endpoints, Datasource, and Response Parsing Fix

> **Role:** You are a senior Flutter integration engineer fixing Cart datasource compliance.  
> **Task:** Update `CartRemoteDataSource` to use the exact endpoints and HTTP methods from `cart_API_CONTRACT.md`. Add a `patch()` method to `DioClient`. Update `CartItemModel.fromMap()` to parse the backend's snake_case field names (`cart_item_id`, `menu_item_id`, `unit_price_snapshot`, `line_total`). Update `ApiEndpoints` with the correct cart paths.  
> **Context:** The current datasource uses wrong paths (`/carts/{cartId}`) and wrong HTTP methods (PUT instead of PATCH). The backend stores prices in pennies (`unit_price_snapshot`); the model must convert to a `double` for display. The `CartRemoteDataSource` must look for cart items under the `items` key in the response object.  
> **Format:** Show each changed file path, what changed, and the complete updated code.  
> **Constraints & Examples:** Do not change any widget or screen file. The `cart_API_CONTRACT.md` is the only source of truth for field names and response shape.

---

#### Prompt 3 — Cubit & Add-to-Cart Menu Wiring

> **Role:** You are a Flutter feature-integration specialist focused on state management and request flow wiring.  
> **Task:** Wire the "Add to Cart" button in `MenuItemDetailsSheet` to `CartCubit.addItem`. The `addItem` method must call `AddCartItemUseCase`, which calls `CartRepository.addItem`, which calls `CartRemoteDataSource.addItem` with `POST /api/cart/items/`.  
> **Context:** `MenuItemDetailsSheet` already has an `ElevatedButton` with `onPressed: () {}`. It has access to the menu item's `id` and the selected `quantity` from its local state. The `CartCubit` needs to be provided in the widget tree above `MenuItemDetailsSheet` — this is already done through the shell route.  
> **Format:** Show the cubit method, use case, repository contract update, datasource implementation, and the minimal widget change needed to call `context.read<CartCubit>().addItem(menuItemId: item.id, quantity: quantity)`.  
> **Constraints & Examples:** Do not modify `MenuScreen` or any other widget outside `MenuItemDetailsSheet`. The `account_id` used in the POST body comes from the currently authenticated user's stored account ID.

---

#### Prompt 4 — Cart Delete Action Wiring

> **Role:** You are a senior Flutter engineer responsible for interaction-to-API wiring.  
> **Task:** Wire the trash icon in `CartItemCard` to `CartCubit.removeItem`. The `removeItem` method must call `RemoveCartItemUseCase`, which calls `CartRepository.removeItem`, which calls `CartRemoteDataSource.removeItem` with `DELETE /api/cart/items/<cart_item_id>/delete/`.  
> **Context:** `CartItemCard` already has an `IconButton` with `Icons.delete_outline` and `onPressed: () {}`. It receives the `CartItemEntity` model which has an `id` field corresponding to `cart_item_id`. After deletion the backend returns the updated cart object, so the cubit must update state with the new items list.  
> **Format:** Show the updated `CartItemCard` (minimal change to `onPressed`), the `removeItem` method in `CartCubit`, and the datasource implementation.  
> **Constraints & Examples:** Do not change the card's layout, styling, or any other callback. Do not modify `CartMainSection` or `CartScreen`.

---

### 3. Verification & Audit (The Human Bun)

**Contract Compliance Check:**
- All endpoints, HTTP methods, query params, and body fields match `Docs/cart_API_CONTRACT.md`.
- `CartItemModel.fromMap()` parses `cart_item_id`, `unit_price_snapshot` (pennies to double), `menu_item_name`, and `menu_item_description` from the backend response.

**Integration Integrity Check:**
- "Add to Cart" in `MenuItemDetailsSheet` calls `CartCubit.addItem`, which flows through use case → repository → datasource → `POST /api/cart/items/`.
- Trash icon in `CartItemCard` calls `CartCubit.removeItem`, which flows through use case → repository → datasource → `DELETE /api/cart/items/<id>/delete/`.
- Increment/decrement uses `PATCH /api/cart/items/<id>/` with a `quantity` body.

**Scope & Safety Check:**
- No backend file was modified.
- No screen, layout, or styling was changed outside the minimal `onPressed` wires in `MenuItemDetailsSheet` and `CartItemCard`.
- Widget tests in `test/features/cart/` cover cubit state transitions, model parsing, and action flows.

---

### 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| Get cart by account ID | `GET /api/cart/?account_id=<id>` returns cart with nested items | Pass |
| Add item from menu to cart | `POST /api/cart/items/` creates item; cart state updates | Pass |
| Delete item via trash icon | `DELETE /api/cart/items/<id>/delete/` removes item; cubit reflects updated list | Pass |
| Update quantity (increment/decrement) | `PATCH /api/cart/items/<id>/` with new quantity; totals recalculate | Pass |
| Pennies-to-dollars conversion | `unit_price_snapshot` (e.g. 1500) renders as `$15.00` in the UI | Pass |
| Non-cart feature stability | Menu, orders, and payment features unaffected | Pass |

---

## Part 4: Place Order (UC4) (Django REST Framework + Flutter Frontend)

### 1. Specification (The Architect Bun)

**Functional Requirement (FR4):** The system shall allow an authenticated customer to convert their active cart into a confirmed order by submitting a delivery address. The order must be assigned a unique ID and set to status `PENDING` upon creation.

**Functional Requirement (FR3 — dependency):** The cart must be non-empty and all items must still be available at the time of order placement.

**Non-Functional Requirement (NFR 1 — Security):** All order endpoints must be protected by JWT bearer token authentication. The `account_id` must be derived exclusively from the token payload — never from the request body or query parameters. Supplying an `account_id` in the request body must be silently ignored.

**Non-Functional Requirement (NFR 2 — Integrity):** The order total must be computed exclusively from live database prices, never from cart price snapshots. All order creation steps (order row, order items, cart clearing, status history seeding) must execute inside a single atomic transaction — any failure must roll back all writes. The cart must be preserved on failure so the customer can retry.

**Non-Functional Requirement (NFR 3 — Idempotency):** A 30-second idempotency window must prevent duplicate orders from double-click or network retry scenarios (EC-UC4-02). If a `PENDING` or `CONFIRMED` order already exists for the same account within that window, the existing order must be returned.

**Edge Cases Addressed:**
- EC-UC4-01: Empty cart must be rejected server-side even if bypassed via direct API call.
- EC-UC4-02: Duplicate order submission guard via idempotency window.
- EC-UC4-04: Price tampering prevention — server recalculates total from live DB.
- EC-UC3-01: Items that became unavailable after the menu loaded must block placement.

**Data Privacy:** Prices are stored and computed in pennies internally. All monetary values are returned to clients as dollar floats (`total_amount / 100.0`). No PII flows through service methods.

---

### 2. Implementation (The AI Meat)

#### Prompt 1 — TDD: Write Tests First for the Order Service

> Write the unit tests for the `OrderService.place_order` method before implementing it. The tests should cover: placing a valid order returns an Order object with status PENDING, the total is computed in pennies from live DB prices (not snapshots), order items are created with snapshots, the cart is cleared after success, an empty cart returns an error without creating any DB rows, a missing cart returns an error, an unavailable item returns an error and does not clear the cart, a mixed available/unavailable cart fails atomically (no order or item rows created), and the 30-second idempotency window returns the same order on a duplicate submit.

---

#### Prompt 2 — TDD: Write Tests First for the Order API Endpoints

> Now write the API-level tests for `POST /api/order/place/` and `GET /api/order/` before implementing the views. Cover: authentication guard (401 without token, 401 with invalid token, 401 for inactive account), the response shape has all required fields (`orderId`, `accountId`, `status`, `placedAt`, `totalAmount`, `progress`, `items`), `totalAmount` is a float in dollars, `status` is PENDING, `progress` is a float in [0.0, 1.0], `accountId` matches the token, items are nested correctly with `id`/`title`/`unitPrice`/`quantity`/`lineTotal`, the account cannot be injected via request body, the cart is cleared on success, 400 is returned for an empty cart with a helpful message, 400 for an unavailable item naming the item in the error, cart is preserved on failure, 400 for missing address, the total uses live DB prices not the cart snapshot, a duplicate within 30 seconds returns the same order ID and only one DB row, and the list endpoint returns only the authenticated account's orders newest-first.

---

#### Prompt 3 — Implement the Order Models

> Implement `apps/order/models.py` with the `Orders`, `OrderItems`, and `OrderStatusHistory` models to match the ERD. `Orders` should have `order_id` (UUID PK), `account` (FK to authentication.Accounts), `total_amount` (int pennies), `placed_at`, `order_status`, `confirmed_at` (nullable), `updated_at`, and `address`. `OrderItems` should snapshot `item_name_snapshot`, `item_description_snapshot`, `unit_price_snapshot`, `quantity`, and auto-compute `line_total` in `save()`. `OrderStatusHistory` should store `order_status`, `note`, and `changed_at`. Make sure migrations are generated cleanly.

---

#### Prompt 4 — Implement the Order Service

> Now implement `apps/order/services.py` with `OrderService.place_order(account_id, address)` and `OrderService.get_orders_for_account(account_id)`. `place_order` must: (1) check the 30-second idempotency window first, (2) run all DB writes inside `transaction.atomic()`, (3) fetch the cart, (4) reject an empty cart, (5) validate every item is still available, (6) recompute the total from live `menu_item.price_penny` — never from `unit_price_snapshot`, (7) create the `Orders` row, (8) create one `OrderItems` row per cart item with snapshots, (9) call `CartService.clear_cart()`, and (10) seed an initial `OrderStatusHistory` entry with status PENDING. Use a private `_ValidationError` sentinel to trigger rollback from inside the atomic block. Run the tests — all must pass.

---

#### Prompt 5 — Implement Serializers

> Implement `apps/order/serializers.py`. `OrderItemLineSerializer` must map `order_item_id → id`, `item_name_snapshot → title`, `unit_price_snapshot / 100.0 → unitPrice`, `line_total / 100.0 → lineTotal`. `OrderSerializer` must map `order_id → orderId`, `account_id → accountId`, `order_status → status`, `placed_at → placedAt`, `total_amount / 100.0 → totalAmount`, compute `progress` from a `_PROGRESS_MAP` (PENDING=0.1, CONFIRMED=0.25, PREPARING=0.5, READY=0.75, OUT_FOR_DELIVERY=0.9, DELIVERED=1.0, terminal statuses=0.0), and nest `items` using `OrderItemLineSerializer`. `PlaceOrderSerializer` validates only `address` (max 500 chars) and silently ignores any other fields the client sends. Make sure the Flutter `OrderItemModel.fromMap` field names are matched exactly.

---

#### Prompt 6 — Implement Views and URLs

> Implement `apps/order/views.py` with `list_orders` (GET, returns all orders for the token account newest-first) and `place_order` (POST, validates body with `PlaceOrderSerializer`, calls `OrderService.place_order`, returns 201 on success or 400 with `{"error": "…"}` on failure). Add `apps/order/urls.py` mounting them at `""` and `"place/"` respectively. Wire into `config/urls.py` at `api/order/`. Re-run all order tests — they must all pass.


---

### 3. Verification & Audit (The Human Bun)

**Dependency Audit:**
- All backend imports are from Django stdlib, DRF, or `rest_framework_simplejwt`. No new packages were introduced.
- `transaction.atomic()` is used correctly — the `_ValidationError` sentinel is raised inside the atomic block so the context manager sees an exception and rolls back.

**Security Check:**
- Verified `test_place_order_uses_account_from_token_not_body`: passing `"account_id": account_b.account_id` in the request body still creates the order under account A — the view reads only from the JWT via `request.user.account_id`.
- Verified `test_list_orders_account_id_comes_from_token`: passing `?account_id=account_b` as a query parameter still returns only account A's orders.

**Logic Fixes:**
- AI initially computed `total_amount` from `cart_item.unit_price_snapshot` (the cart snapshot). Fixed to use `cart_item.menu_item.price_penny` (live DB price) to satisfy EC-UC4-04 and the test `test_place_order_total_uses_live_price_not_snapshot`.
- AI placed cart-clearing before availability validation, meaning a failed order would still clear the cart. Fixed by moving `CartService.clear_cart()` to after all validation and DB writes succeed inside the atomic block.
- AI returned `HTTP_201_CREATED` even when `OrderService.place_order` returned an error tuple. Fixed to check `if error:` and return `HTTP_400_BAD_REQUEST` with `{"error": error}`.
- AI omitted `_ensure_accounts_table()` in `setUpClass`, causing `OperationalError: no such table: accounts`. Fixed by calling it in every `TestCase.setUpClass`.
- AI used `RefreshToken.for_user(django_user)` which is incompatible with the custom `Accounts` model. Replaced with `RefreshToken()` and manual claim injection (`account_id`, `email`, `role`, `display_name`).
- AI forgot to seed `OrderStatusHistory` after order creation. Added `OrderStatusHistory.objects.create(...)` at step 10 of `place_order`, which was required by `test_place_order_creates_initial_history_entry`.
- `_PROGRESS_MAP` initially returned `0` for `PENDING` instead of `0.1`. Corrected to match the API contract and `test_progress_value_for_pending_status`.

---

### 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| `POST /api/order/place/` without token | `401 Unauthorized` | |
| `POST /api/order/place/` with invalid token | `401 Unauthorized` | |
| `POST /api/order/place/` with inactive account token | `401 Unauthorized` | |
| `POST /api/order/place/` with valid cart | `201 Created`, `status = PENDING` | |
| Response has all required fields | `orderId`, `accountId`, `status`, `placedAt`, `totalAmount`, `progress`, `items` present | |
| `totalAmount` for 2×£10.00 items | `20.00` (float dollars) | |
| `progress` for PENDING order | `0.1` (float in [0.0, 1.0]) | |
| `accountId` in response | Matches token, not request body | |
| Request body contains `account_id` of another user | Order still created under token account | |
| Cart is cleared after successful placement | `CartItem` count = 0 | |
| `POST /api/order/place/` with empty cart | `400 Bad Request`, message contains "empty" | |
| `POST /api/order/place/` with unavailable item | `400 Bad Request`, item name in error message | |
| Cart preserved when item is unavailable | `CartItem` count unchanged | |
| `POST /api/order/place/` missing address | `400 Bad Request` | |
| Total computed from live DB price, not snapshot | `totalAmount` reflects `price_penny`, not tampered `unit_price_snapshot` | |
| Duplicate submit within 30 seconds | Same `orderId` returned, only 1 order row in DB | |
| Mixed available/unavailable items in cart | No `Orders` or `OrderItems` rows created (atomic rollback) | |
| `OrderStatusHistory` seeded on placement | At least 1 history row with status PENDING | |
| `GET /api/order/` without token | `401 Unauthorized` | |
| `GET /api/order/` returns only own orders | Other account's orders excluded | |
| `GET /api/order/` returns newest first | `placedAt` descending | |
| `?account_id=other` query param in list | Ignored — returns token holder's orders only | |

---



## Part 5: Orders Contract Integration (Flutter Frontend)

### 1. Specification (The Architect Bun)

**Functional Requirement:** The Orders frontend integration must match `Docs/order_API_CONTRACT.md` exactly — endpoints, HTTP methods, request/response field names, and authentication handling.

**Functional Requirement:** The "Proceed to Checkout" button in `CartOrderSummaryCard` must create an order via `POST /api/orders/` and store the returned `order_id` in `OrdersCubit` state so it can be passed to the payment screen.

**Non-Functional Requirement:** No UI, widget, screen layout, or backend file may be modified. Only Orders data/domain layers and cubit integration are in scope.

---

### 2. Implementation (The AI Meat)

#### Prompt 1 — Contract-Accurate Orders Integration

> **Role:** You are a senior Flutter integration engineer focused on contract-accurate feature delivery.  
> **Task:** Compare the current `OrdersRemoteDataSource`, `OrdersRepositoryImpl`, and `OrdersCubit` against `Docs/order_API_CONTRACT.md`. Identify every mismatch and fix the integration layer only.  
> **Context:** The backend exposes `GET /api/orders/?account_id=<id>` to list orders and `POST /api/orders/` to create an order. Order objects have fields including `order_id`, `account_id`, `order_status`, `total_amount`, `placed_at`, and `items`. The `order_API_CONTRACT.md` is the single source of truth. The `ERD.md` confirms the `ORDERS` and `ORDER_ITEMS` tables.  
> **Format:** Return a change summary grouped by datasource, repository, use case, and cubit wiring.  
> **Constraints & Examples:** Do not modify the backend or any widget/screen file. Authentication is handled by the `DioClient` interceptor — datasources must not add auth headers manually.

---

#### Prompt 2 — Create Order + Pending State + Payment Handoff

> **Role:** You are a Flutter domain-flow engineer ensuring lifecycle correctness.  
> **Task:** Add a `createOrder(String accountId)` method to `OrdersCubit` that calls `CreateOrderUseCase`, which calls `POST /api/orders/`. On success, store the returned `order_id` in `OrdersState` as `pendingOrderId`. Emit an `OrdersRequestStatus.success` state. Leave a `// TODO: navigate to payment screen` comment at the handoff point, as the payment screen is built in a separate sprint.  
> **Context:** The order lifecycle defined in `Docs/order_API_CONTRACT.md` is: `pending → paid` after payment confirmation. A newly created order has `order_status: "pending"`. The `CartOrderSummaryCard` "Proceed to Checkout" button currently has `onPressed: () {}` — this is where `CartCubit` will delegate to `OrdersCubit.createOrder` or the router navigates to checkout.  
> **Format:** Show the `OrdersState` field addition (`pendingOrderId`), the cubit method, the use case, the repository contract method, and the datasource request.  
> **Constraints & Examples:** Do not create a payment screen in this sprint. The `pendingOrderId` is what the payment screen will read when it is built.

---

#### Prompt 3 — Orders Screen Data Cleanup

> **Role:** You are a senior Flutter product engineer aligning screens with real backend capabilities.  
> **Task:** Update `OrdersMainColumn` and `OrderStatusCard` to render data from `OrderItemEntity` fields only: `orderId`, `accountId`, `status`, `placedAt`, `totalAmount`, and `progress`. Remove any placeholder elements not backed by the API contract (reward banners, points, non-functional "Track" buttons that have no backend).  
> **Context:** The orders screen previously showed static placeholder content alongside real order data. The `order_API_CONTRACT.md` defines exactly which fields are returned. The `Docs/ERD.md` `ORDER_STATUS_HISTORY` table confirms that status tracking exists in the backend, but real-time tracking endpoints are not yet exposed.  
> **Format:** List removed elements and the final data fields displayed.  
> **Constraints & Examples:** Keep the visual structure stable. Only remove elements that have no backend support. Do not change the `SegmentedButton` for active/past tab switching.

---

#### Prompt 4 — Readable Order Presentation

> **Role:** You are a UX-oriented Flutter engineer improving data readability without redesigning.  
> **Task:** Replace raw technical identifiers in `OrderStatusCard` with human-readable labels. Show `Order #<orderId>` instead of the raw UUID. Show the formatted `placedAt` date. Show `$<totalAmount>` with two decimal places.  
> **Context:** The backend returns `order_id` as a UUID and `total_amount` as a decimal. `OrderStatusCard` was previously displaying raw field labels like `account_id: ACC-100 • placed_at: 2026-05-12 12:45` with snake_case names visible to users.  
> **Format:** Provide a small mapping list: `raw field → user-facing label/value`.  
> **Constraints & Examples:** Do not fabricate data. Do not change the card's layout, colors, or spacing. Changes are minimal text formatting only.

---

#### Prompt 5 — Test Alignment

> **Role:** You are a Flutter testing engineer keeping tests aligned with the current integration state.  
> **Task:** Update `OrdersCubit` unit tests in `test/features/orders/` to cover: `loadOrders` success (active/past split), `loadOrders` error state, tab switching between active and past, and the `createOrder` method setting `pendingOrderId` on success.  
> **Context:** Tests were previously using the `_FakeOrdersRepository` pattern established in `widget_test.dart`. The new `createOrder` method needs its own fake repository method returning an `OrderItemEntity` with `order_status: pending`. The existing `orders cubit switches between active and past tabs` test in `widget_test.dart` must remain passing.  
> **Format:** Return the list of test cases added or updated and what each covers.  
> **Constraints & Examples:** Do not add a payment screen just to satisfy tests. Do not import from payment files that do not yet exist.

---

### 3. Verification & Audit (The Human Bun)

**Contract Compliance Check:**
- `GET /api/orders/?account_id=<id>` and `POST /api/orders/` match `Docs/order_API_CONTRACT.md` in endpoint, method, and response parsing.
- Active/past order split is based on `order_status` values as defined in the contract (`delivering`, `preparing` → active; `delivered`, `cancelled` → past).

**Checkout Continuity Check:**
- "Proceed to Checkout" creates an order and stores `pendingOrderId` in `OrdersState`.
- A `// TODO` comment marks the navigation handoff point for the payment sprint.

**UI Purpose Check:**
- Reward banners, points, and non-functional tracking controls removed from `OrdersSummaryCard`.
- All remaining displayed data comes from `OrderItemEntity` fields backed by the API contract.

---

### 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| Proceed to checkout | Order is created and order ID is retained | Pass |
| New order status before payment | Status appears as pending | Pass |
| Orders screen data rendering | API-backed data is shown in readable format | Pass |
| Removed non-functional elements | Reward/points/unused controls no longer appear | Pass |
| Widget test for app flow | Tests compile and run with current route/import setup | Pass |


---
## Sprint 2: Authentication and Payment 
---
## Part 1: Auth Flow Consistency (Flutter Frontend)
---

## 1. Specification (The Architect Bun)

**Functional Requirement:** Authentication-sensitive flows must use bearer-token authorization consistently across all protected API requests.

**Functional Requirement:** Protected API requests must attach the `Authorization: Bearer <token>` header through a single, centralized mechanism in the `DioClient` interceptor — not per-datasource.

**Non-Functional Requirement:** Auth wiring must preserve the existing Clean Architecture layering and DI conventions without introducing broad refactors.

---

## 2. Implementation (The AI Meat)

### Prompt 1 — Scope Alignment + Integration Baseline

> **Role:** You are a senior Flutter engineer responsible for integration consistency across authenticated features.  
> **Task:** Focus implementation strictly on the frontend integration layers. Confirm which files are in scope (datasources, repositories, use cases, cubit wiring, DI, and `DioClient`). Do not touch the backend or any UI/widget files.  
> **Context:** The project uses a feature-first Clean Architecture. The `DioClient` in `Core/network/dio_client.dart` is the single HTTP client shared across all features. The `cart_API_CONTRACT.md` specifies that all endpoints require `Authorization: Bearer <JWT_TOKEN>`.  
> **Format:** List what is in scope vs. out of scope before touching any code.  
> **Constraints & Examples:** Do not duplicate token injection across multiple datasource files. Attach auth headers once in the `DioClient` interceptor's `onRequest` callback. Reference the `cart_API_CONTRACT.md` and `order_API_CONTRACT.md` in `Docs/` as the authoritative authentication requirements.

---

### Prompt 2 — Test Entry Wiring

> **Role:** You are a Flutter QA-focused engineer aligning integration tests with the real app auth flow.  
> **Task:** Update the `widget_test.dart` bootstrap so that `setupDependencies()` is called before `pumpWidget`, ensuring the DI container is initialized before any cubit resolves from `getIt`.  
> **Context:** Tests were previously calling `pumpWidget` on `MyApp()` without initializing DI, causing `GetIt` to throw because cubits were not registered. The test file lives at `test/widget_test.dart`. It already had tests for route paths, theme config, DI singleton assertions, and cubit state transitions.  
> **Format:** Show the minimal change needed: add `setupDependencies()` inside `testWidgets` before `pumpWidget`. Do not rewrite unrelated test cases.  
> **Constraints & Examples:** Keep all existing assertions. Do not add new feature tests in this prompt — that is handled separately in the shared tests sprint.

---

### Prompt 3 — Centralized Bearer Token Injection

> **Role:** You are an API security integration engineer for Flutter clients.  
> **Task:** Update the `DioClient._setupInterceptors()` `onRequest` callback to read the stored JWT access token from `SharedPreferences` and attach it as `Authorization: Bearer <token>` on every outgoing request. This must be the single injection point across all features.  
> **Context:** The cart feature already expects the header as shown in `cart_API_CONTRACT.md` (`Authorization: Bearer <JWT_TOKEN>`). The order and payment features follow the same pattern per their respective contracts. No datasource should manually attach auth headers.  
> **Format:** Return the updated `dio_client.dart` showing the interceptor change only.  
> **Constraints & Examples:** Read the token from `SharedPreferences` using the same key used when storing the token on login. Do not touch any datasource, repository, or use case file.

---

### Prompt 4 — Request Diagnostics + Debug Logging

> **Role:** You are a debugging specialist for Flutter networking and auth propagation.  
> **Task:** Add temporary debug logging to `DioClient` to confirm requests are being sent, URLs are constructed correctly, and errors are surfacing. Log request URL, headers, status code, and response body on both success and failure paths.  
> **Context:** Debugging revealed that requests were reaching the backend and receiving 400 responses. The root cause was missing auth tokens — the backend's `IsAuthenticated` guard was rejecting unauthenticated requests. The `FRONTEND_DEBUGGING.md` created during this sprint documents the request/response traces.  
> **Format:** Show `debugPrint` additions inside the interceptor and each HTTP method. Frame findings as `Symptom → Likely Cause → Confirmed Fix`.  
> **Constraints & Examples:** Logging is temporary and for diagnostic use. Do not change any endpoint path, HTTP method, or payload format.

---

## 3. Verification & Audit (The Human Bun)

**Access-Control Check:**
- Bearer token injection is handled once in `DioClient._setupInterceptors()` and applies to every outgoing request.
- No datasource manually attaches auth headers.

**Test Bootstrap Check:**
- `widget_test.dart` calls `setupDependencies()` before `pumpWidget`, preventing `GetIt` resolution failures.
- All existing test assertions for routes, themes, DI singletons, and cubit state transitions remain in place.

**Architecture Check:**
- No datasource, repository, use case, or widget file was changed for auth wiring.
- Existing DI registrations and feature layering were preserved.

---

## 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| App/test bootstrap | `setupDependencies()` runs before cubit resolution | Pass |
| Protected API call without token | Backend returns `401 Unauthorized` per `cart_API_CONTRACT.md` | Pass |
| Protected API call with token | Request succeeds; DioClient interceptor log confirms `Authorization` header was attached | Pass |
| Cross-feature token reuse | Cart, orders, and payment datasources share the same DioClient interceptor path | Pass |
| Unrelated feature stability | No regression in menu, orders, or payment feature behavior | Pass |


---
## Part 2: Payment Backend Rollout (Django Backend)
---
## 1. Specification (The Architect Bun)

**Functional Requirement:** Implement Stripe PaymentIntent flow in a new `payments` Django app, with order-linked payment records and contract-aligned responses.

**Functional Requirement:** Payment creation must validate order ownership, compute amount server-side from DB order totals, and return `client_secret` and `payment_intent_id` for the Flutter Stripe SDK.

**Non-Functional Requirement:** Use environment-variable key management, idempotency safeguards, and atomic transaction-safe updates while preserving the existing backend architecture style (`authentication`, `cart`, `menu`, `order` apps).

---

## 2. Implementation (The AI Meat)

### Prompt 1 — Production-Grade Payment Build

> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Implement a production-grade Stripe PaymentIntent workflow in the existing Django backend, following the architecture of the `cart` and `order` apps exactly. Create a new `payments` app under `src/back/apps/payments/` with `models.py`, `serializers.py`, `services.py`, `views.py`, `urls.py`, and `adapters.py`.
> **Context:** The Flutter frontend already exists and must not be touched. The backend follows a modular apps structure. Reference `Docs/checkout_API_CONTRACT.md` as the endpoint contract and `src/back/database/schema.sql` for the DB schema. Tests in `src/back/apps/payments/tests.py` are the highest-priority source of truth and must all pass.
> **Format:** Analyze the repository architecture first, state where payment logic belongs and why, list files to create/modify, then implement immediately. Return full code with file paths, migration files, environment setup, and test execution commands.
> **Constraints & Examples:** Never trust client-provided amounts — compute from DB order totals only. Never hardcode Stripe keys; use `STRIPE_SECRET_KEY`, `STRIPE_PUBLISHABLE_KEY`, and `STRIPE_WEBHOOK_SECRET` from `.env`. Use Stripe idempotency to prevent duplicate charges. Validate order ownership before creating a PaymentIntent. Return `client_secret`, `payment_intent_id`, `payment_id`, `checkout_url`, and `status` as defined in `Docs/checkout_API_CONTRACT.md`.

---

### Prompt 2 — Migration and Test Recovery

> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Diagnose and fix all migration and test failures introduced during the payment rollout. The test suite is blocked by two issues: `no such column: categories.category_name` breaking test DB setup, and `table "payments" already exists` blocking migration on an existing DB.
> **Context:** The payments implementation exists but CI is failing. The `categories` table column name in `menu/models.py` drifts from the SQL schema used in `payments/tests.py` fixture setup. The payments migration conflicts with a pre-existing `payments` table in the dev DB. Reference the existing migration patterns in `order/migrations/0001_initial.py` and `cart/migrations/0001_initial.py` for correct dependency ordering.
> **Format:** Provide a concise fix log with each failure, its root cause, and the exact remediation applied.
> **Constraints & Examples:** Fix migration dependency ordering and model field alignment rather than disabling or skipping tests. Use `--fake-initial` to reconcile existing DB state cleanly. All 72 tests across `apps.cart.tests`, `apps.order.tests`, and `apps.payments.tests` must pass.

---

### Prompt 3 — Authorization Header Parity

> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Update all payment views to match the cart app's bearer-token authentication pattern exactly. Read `account_id` from `request.user.account_id` (resolved from the JWT token) and return `{"error": "Authentication token is required"}` with HTTP 401 when no token is present.
> **Context:** The cart views in `src/back/apps/cart/views.py` already demonstrate the expected pattern using `@permission_classes([IsAuthenticated])` and a `_get_request_account_id(request)` helper. Payment endpoints must follow the identical approach — no custom auth semantics, no account ID from the request body or query params. Reference `Docs/checkout_API_CONTRACT.md` which specifies `Authorization: Bearer <access_token>` for all payment endpoints.
> **Format:** Return one clear auth rule and where it is enforced in the payment views.
> **Constraints & Examples:** Do not create custom authentication classes for payment. Mirror the cart pattern: `@api_view`, `@permission_classes([IsAuthenticated])`, and `_get_request_account_id(request)`.

---

### Prompt 4 — Contract Synchronization

> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Update `Docs/checkout_API_CONTRACT.md` to accurately reflect the current backend implementation. Remove fields not present in the real payment flow and add fields the backend actually returns. Ensure endpoint paths, HTTP methods, request bodies, and response schemas all match the live implementation.
> **Context:** The original contract contained drift: it listed `amount` as a request field for `POST /api/payments/create-session/` (not sent by the real backend flow) and was missing fields like `payment_intent_id` and `client_secret` from the response. Reference `Docs/order_API_CONTRACT.md` and `Docs/cart_API_CONTRACT.md` as consistency anchors. There is no `address` field in the payment creation request.
> **Format:** Provide the updated contract with method, request body, response schema, and field notes for each payment endpoint.
> **Constraints & Examples:** Remove `address` from any payment payload — it is not part of the payment creation flow. Include both snake_case canonical fields and camelCase compatibility aliases where the backend currently returns both.

---

### Prompt 5 — Workflow Documentation

> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Write `Docs/checkout_payment_workflow.md` — a step-by-step markdown guide documenting the exact end-to-end payment lifecycle for the team.
> **Context:** The team needs a practical, implementation-aligned reference for local setup and production-like testing. It should cover the full happy path from cart fetch through Stripe webhook confirmation, and document the webhook signing secret setup. Reference the finalized `Docs/checkout_API_CONTRACT.md` as the source of truth for endpoint shapes.
> **Format:** Use step-by-step sections: `Authenticate`, `Get Cart`, `Validate Cart`, `Place Order`, `Create Payment Session`, `Client Stripe Confirmation`, `Check Payment Status`, `Retry Payment`, `Webhook Handling`, and a `Status Summary` table.
> **Constraints & Examples:** Include exactly how to obtain the webhook signing secret and where to place `STRIPE_WEBHOOK_SECRET` in the `.env`. Document that the backend always reads `account_id` from the JWT token — never from the request body.

---

## 3. Verification & Audit (The Human Bun)

**Security & Integrity Check:**
- Amount is calculated from DB order totals; no client-provided amount is trusted.
- Auth and ownership validation are required before payment intent creation.
- Stripe keys are loaded from environment variables only; none are hardcoded.

**Stripe Flow Check:**
- Backend creates and stores `Payment` and `PaymentTransaction` records tied to the order.
- `client_secret` and `payment_intent_id` are returned for the Flutter Stripe SDK to consume.
- Webhook signature verification uses `STRIPE_WEBHOOK_SECRET` before any status updates.

**Operational Check:**
- `Docs/checkout_payment_workflow.md` documents the full lifecycle including webhook setup.
- `Docs/checkout_API_CONTRACT.md` is synchronized with the live implementation, with no stale or hypothetical fields.
- Migration conflicts on existing DBs are resolved with `--fake-initial`.

---

## 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| Create payment intent for valid order | Returns `client_secret`, `payment_intent_id`, and `payment_id` | Pass |
| Create payment intent with invalid ownership | Request is rejected with 403/404 | Pass |
| Amount calculation source | Uses DB order totals, not client input | Pass |
| Duplicate payment prevention | Idempotency safeguard blocks a second intent for the same order | Pass |
| Auth header handling | Bearer-token pattern matches cart and order protected endpoints | Pass |
| Webhook signature verification | Invalid signature returns 400; valid signature updates payment and order status | Pass |
| Migration on existing DB | `--fake-initial` applies `payments` migrations cleanly without conflict | Pass |
| Full test suite | All 72 tests across cart, order, and payments pass | Pass |
---
## Sprint 3: Notifications and Order Tracking 
---
## Part 1: Notifications Feature Implementation

## 1. Specification (The Architect Bun)

**Functional Requirement (FR7):** The system shall send order confirmation notifications to authenticated customers after successful order placement and payment confirmation.

**Functional Requirement (FR8):** The system shall update customers with order status notifications throughout the order lifecycle.

**Functional Requirement (FR9):** The customer shall be able to track notifications and order status updates from the frontend notification center.

**Non-Functional Requirement (NFR1):** Notification endpoints and status retrieval operations must respond within ≤ 2 seconds.

**Non-Functional Requirement (NFR3):** All notification-related communication and API endpoints must use secure HTTPS and JWT authentication.

**UC6 — Send Confirmation:** After successful payment, the system shall generate and send order confirmation notifications containing order details and estimated completion information.

**UC7 — Track Order:** Customers shall receive order status updates and view real-time order progress through the notification feature.

---

## 2. Implementation (The AI Meat)

### Prompt 1 — Frontend Notifications Architecture

> You are implementing a Notifications feature in an existing Flutter application.
>
> Important constraints:
>
> * Follow the current project architecture exactly.
> * Reuse existing app theme, typography, colors, spacing, dimensions, extensions, utilities, and shared widgets.
> * Use Cubit for state management.
> * Create reusable responsive widgets.
> * Implement notification bell, unread badge, popup overlay, notifications page, loading states, empty states, and unread synchronization.
> * Generate a backend API contract that aligns with the frontend architecture.

---

### Prompt 2 — Remove Frontend Dummy Data

> can you check for the notification feature in the front end? i want you to remove all the dummy data for it.

---

### Prompt 3 — Backend Notifications Feature with Tests

> I want to implement the back for the notification feature. I attached generated models file, that you should use to make a models.py for the backend i also attach the API_contract that the front is expecting, follow the same architecture as the other backend features. also remove the dummy data for notification from the front, and also make the red badge for notification reflect the actual amount of notifications. and the notification service should send a notification to the user when the order is placed, and every time there is a change in the order status. also start first with a Test Driven Approach, before the actual implementation, so i can see the expected output structure. 

---

### Prompt 4 — TDD Failure Phase

> The notification serializer tests are failing. Check why the serializer output does not match the frontend expectations and fix the API response structure and timestamp formatting.

> Test GET /api/notifications/list returns paginated response. ... ERROR
> test_get_unread_count_endpoint (tests.NotificationAPITestCase.test_get_unread_count_endpoint)
> Test GET /api/notifications/unread-count returns count. ... ERROR
> test_mark_all_as_read_endpoint (tests.NotificationAPITestCase.test_mark_all_as_read_endpoint)
> Test PATCH /api/notifications/mark-all-read marks all as read. ... ERROR
> test_mark_as_read_endpoint (tests.NotificationAPITestCase.test_mark_as_read_endpoint)
> Test PATCH /api/notifications/{message_id}/read marks notification. ... ERROR
> test_notification_timestamp_format_in_response (tests.NotificationAPITestCase.test_notification_timestamp_format_in_response)
> Test notification timestamps in API response are ISO 8601 UTC. ... ERROR
> test_pagination_query_parameters (tests.NotificationAPITestCase.test_pagination_query_parameters)
> Test pagination with different page and limit parameters. ... ERROR
> test_unauthorized_request_returns_401 (tests.NotificationAPITestCase.test_unauthorized_request_returns_401)
> Test endpoints return 401 without authentication. ... ERROR
> test_create_notification_with_all_fields (tests.NotificationMessageModelTestCase.test_create_notification_with_all_fields)
> Test creating notification with all fields. ... ERROR
> test_create_notification_with_order (tests.NotificationMessageModelTestCase.test_create_notification_with_order)
> Test creating notification linked to an order. ... ERROR
> test_notification_order_nullable (tests.NotificationMessageModelTestCase.test_notification_order_nullable)
> Test that order can be null (promotional notifications). ... ERROR
> test_notification_sent_at_nullable (tests.NotificationMessageModelTestCase.test_notification_sent_at_nullable)
> Test that sent_at can be null. ... ERROR


---

### Prompt 5 — TDD Success Phase

> Run the full notification test suite again and verify that the notification endpoints, serializers, unread counts, and mark-as-read flows all work correctly with JWT authentication and pagination.

> Test GET /api/notifications/list returns paginated response. ... ok
> test_get_unread_count_endpoint (tests.NotificationAPITestCase.test_get_unread_count_endpoint)
> Test GET /api/notifications/unread-count returns count. ... ok
> test_mark_all_as_read_endpoint (tests.NotificationAPITestCase.test_mark_all_as_read_endpoint)
> Test PATCH /api/notifications/mark-all-read marks all as read. ... ok
> test_mark_as_read_endpoint (tests.NotificationAPITestCase.test_mark_as_read_endpoint)
> Test PATCH /api/notifications/{message_id}/read marks notification. ... ok
> test_notification_timestamp_format_in_response (tests.NotificationAPITestCase.test_notification_timestamp_format_in_response)
> Test notification timestamps in API response are ISO 8601 UTC. ... ok
> test_pagination_query_parameters (tests.NotificationAPITestCase.test_pagination_query_parameters)
> Test pagination with different page and limit parameters. ... ok
> test_unauthorized_request_returns_401 (tests.NotificationAPITestCase.test_unauthorized_request_returns_401)
> Test endpoints return 401 without authentication. ... ok
> test_create_notification_with_all_fields (tests.NotificationMessageModelTestCase.test_create_notification_with_all_fields)
> Test creating notification with all fields. ... ok

---

## 3. Verification & Audit (The Human Bun)

### Dependency Audit

The notification implementation reused existing project dependencies and architecture patterns.

Verified integrations included:

* Django REST Framework
* JWT authentication
* existing authentication models
* Flutter Cubit architecture
* repository abstraction layer
* dependency injection system
* existing application theming system

No unnecessary external packages were introduced.

---

### Backend Verification

The backend notification feature was validated through automated test execution.

The test suite verified:

#### API Endpoints

* GET notifications list endpoint
* GET unread count endpoint
* PATCH mark-as-read endpoint
* PATCH mark-all-as-read endpoint
* pagination query parameter handling
* unauthorized request protection

#### Notification Model Behavior

* notification creation
* nullable order relationships
* nullable sent timestamps
* order-linked notifications
* serializer correctness
* ISO timestamp serialization

#### Notification Service Logic

* notification creation service
* order-linked notification creation
* unread count calculations
* mark-as-read business logic
* bulk mark-all-read behavior

---

### Successful Test Execution

The succeeding test execution confirmed:

* 24 notification tests discovered and executed
* notification migrations applied successfully
* API endpoint tests passing
* pagination responses working correctly
* unread count endpoint functioning
* serializer formatting validated
* notification services operating correctly

Verified passing tests included:

* `test_get_notifications_list_endpoint_returns_pagination`
* `test_get_unread_count_endpoint`
* `test_mark_all_as_read_endpoint`
* `test_mark_as_read_endpoint`
* `test_notification_timestamp_format_in_response`
* `test_pagination_query_parameters`
* `test_unauthorized_request_returns_401`
* `test_create_notification_with_all_fields`
* `test_create_notification_with_order`
* `test_notification_order_nullable`
* `test_notification_sent_at_nullable`
* `test_serializer_output_format`
* `test_serializer_timestamp_iso8601_format`
* `test_serializer_with_null_order_id`
* `test_serializer_with_order_id`
* `test_create_notification`
* `test_create_notification_with_order_id`

---

### Failure Analysis

Earlier failing test runs exposed serializer inconsistencies.

The primary issues detected were:

* serializer output mismatch
* incorrect timestamp formatting
* nullable order serialization issues
* incorrect response payload structure

The failing tests included:

* `test_serializer_output_format`
* `test_serializer_timestamp_iso8601_format`
* `test_serializer_with_null_order_id`
* `test_serializer_with_order_id`

These failures revealed inconsistencies between:

* backend serializer output
* frontend API expectations
* generated API contract specifications

The serializer layer was corrected afterward to align with frontend requirements.
---

## Part 2: Order Tracking Feature
---

### 1. Specification (The Architect Bun)

**Functional Requirement (FR9):** The system shall allow an authenticated customer to retrieve the current tracking status of their order, including a progress value, an estimated time remaining in minutes, and a chronological history of all status changes.

**Functional Requirement (FR8):** The system shall record every order status change in `OrderStatusHistory`, enabling a full timeline to be surfaced to the customer.

**Non-Functional Requirement (NFR 1 — Security):** The tracking endpoint must enforce customer-level authorization. A customer may only track their own orders — requests for another account's order must return `404 Not Found` (not `403 Forbidden`) to prevent order ID enumeration (EC-UC7-01).

**Non-Functional Requirement (NFR 2 — Contract Compliance):** The API response must conform to `tracking_API_CONTRACT.md`: `orderId`, `currentStatus` (lowercase, with `OUT_FOR_DELIVERY` aliased to `"delivery"`), `progress` (integer 0–100), `estimatedTimeMinutes` (non-negative integer, decreasing as status advances, 0 for `DELIVERED`), and `history` (list of `{status, timestamp}` sorted oldest-first, status values also lowercase with the same alias).

**Non-Functional Requirement (NFR 3 — Read-Only):** The tracking endpoint is strictly read-only (`GET` only). `POST`, `PUT`, and `DELETE` must return `405 Method Not Allowed`.

**Edge Cases Addressed:**
- EC-UC7-01: Cross-account tracking attempt returns `404`, not `403`, and leaks no order details.
- EC-UC7-02: Non-existent order ID returns `404` with a `message` field.
- Rate limiting not yet implemented (deferred as per NFR discussion).

**Status Label Mapping (DB → API contract):**

| DB Status | `currentStatus` / history label | `progress` | `estimatedTimeMinutes` |
|---|---|---|---|
| PENDING | pending | 0 | 45 |
| CONFIRMED | confirmed | 20 | 35 |
| PREPARING | preparing | 50 | 20 |
| READY | ready | 70 | 15 |
| OUT_FOR_DELIVERY | delivery | 90 | 5 |
| DELIVERED | delivered | 100 | 0 |
| CANCELLED / REFUNDED / FAILED | (lowercase) | 0 | 0 |

---

### 2. Implementation (The AI Meat)

#### Prompt 1 — TDD: Write Tests First for the Tracking Service

> Write the unit tests for `OrderService.get_order_tracking(order_id, account_id)` before implementing it. Tests must cover: returns the correct order for the authenticated account, returns `(None, None, error)` for a wrong account (EC-UC7-01), returns `(None, None, error)` for a non-existent order ID (EC-UC7-02), returns the history queryset alongside the order, and the history entries are sorted by `changed_at` ascending.

---

#### Prompt 2 — TDD: Write Tests First for the Tracking API

> Write the full API test suite for `GET /api/order/{orderId}/tracking/` before implementing it. Cover: authentication guard (401 without token, 401 with invalid token), `200 OK` for the owner's order, response contains all required fields (`orderId`, `currentStatus`, `progress`, `estimatedTimeMinutes`, `history`), `orderId` in response matches the requested order, `history` is a non-empty list after placement, each history entry has `status` and `timestamp` fields, history is sorted chronologically (oldest-first), `currentStatus` for a freshly-placed PENDING order is the lowercase string `"pending"`, `currentStatus` is correctly mapped for CONFIRMED/PREPARING/READY/READY/OUT_FOR_DELIVERY (→ `"delivery"`)/DELIVERED, `progress` integer matches the contract map for every status, `progress` is always in [0, 100], `estimatedTimeMinutes` is a non-negative integer, ETA decreases monotonically as the order advances through statuses, ETA is 0 for DELIVERED, `404` for another account's order (not `403`), `404` body does not leak the order ID or account ID, `account_id` query param injection is rejected, `404` with `message` field for a non-existent order ID, `404` response does not expose internal details (no traceback/exception/django/sql), endpoint rejects POST/PUT/DELETE with 405, and all seeded history status values are present and lowercase in the response.

---

#### Prompt 3 — Implement the Tracking Service Method

> Add `OrderService.get_order_tracking(order_id, account_id)` to `apps/order/services.py`. It must query `Orders` filtering by both `order_id` and `account_id` — a mismatch on either must raise `Order.DoesNotExist` and return `(None, None, "Order not found.")`. On success, return `(order, history_queryset, None)` where `history_queryset` is `OrderStatusHistory.objects.filter(order=order).order_by("changed_at")`. Run the service-level tracking tests — all must pass.

---

#### Prompt 4 — Implement the Tracking Serializers

> Add `OrderTrackingHistorySerializer` and `OrderTrackingSerializer` to `apps/order/serializers.py`. `OrderTrackingHistorySerializer` must map `changed_at → timestamp` and produce a lowercase `status` string with `OUT_FOR_DELIVERY` aliased to `"delivery"`. `OrderTrackingSerializer` must include all order fields plus `currentStatus` (same lowercase/alias logic), `progress` (integer from `_TRACKING_PROGRESS_MAP`), `estimatedTimeMinutes` (integer from `_ETA_MAP`), and `history` (populated from `self.context["history"]` via `OrderTrackingHistorySerializer`). Progress and ETA maps must be separate from the existing `_PROGRESS_MAP` used by `OrderSerializer` because the tracking contract uses integer percentages (0–100) while the orders list uses float fractions (0.0–1.0).

---

#### Prompt 5 — Implement the Tracking View and URL

> Add `order_tracking(request, order_id)` to `apps/order/views.py`. It must be `GET`-only (`@api_view(["GET"])`), require authentication, call `OrderService.get_order_tracking(order_id, _account_id(request))`, return `404` with `{"message": "Order not found."}` if `error` is set or `order` is `None`, and otherwise serialize with `OrderTrackingSerializer(order, context={"history": history})` and return `200`. Add the URL pattern `"<str:order_id>/tracking/"` to `apps/order/urls.py`. Re-run all tracking tests — they must all pass.

---

#### Prompt 6 — Wire the Flutter Frontend

> On the Flutter side, implement `OrderTrackingEntity` and `TrackingHistoryEntry` domain entities, `OrderTrackingModel` and `TrackingHistoryEntryModel` data models with `fromMap`/`toMap`, `OrdersRemoteDataSource.getOrderTracking(orderId)` in the data source (GET to `/api/order/{orderId}/tracking/`, throw `AppException` on non-200 or invalid format), `GetOrderTrackingUseCase`, `OrderTrackingState` (with `status`, `tracking`, `errorMessage`), and `OrderTrackingCubit` with `loadTracking(orderId)`. The `OrderTrackingScreen` must call `loadTracking` in `initState`, show a `CircularProgressIndicator` while loading, show the `TrackingTimeline` widget driven by `tracking.currentStatus`, render a history list with each entry's capitalized label and formatted timestamp, and display `~${tracking.estimatedTimeMinutes} min remaining` when not yet delivered.

---

#### Prompt 7 — Implement the TrackingTimeline Widget

> Implement the `TrackingTimeline` widget using an enum `OrderTrackingStage` (pending, confirmed, preparing, ready, delivery, delivered) each with a label and icon. The widget must accept `currentStatus` (the lowercase contract string), resolve it to a stage via a map, and render all stages as a horizontal stepper on desktop or a vertical list on mobile. Completed stages use `colorScheme.primary`, the active stage uses `colorScheme.primaryContainer` with a glow shadow, and future stages are rendered at 40% opacity. A foreground progress line overlays the background connector line proportional to the current stage index.

---

### 3. Verification & Audit (The Human Bun)

**Dependency Audit:**
- No new packages introduced. `OrderTrackingSerializer` reuses the existing `OrderItemLineSerializer` for nested items.
- `_TRACKING_PROGRESS_MAP` and `_ETA_MAP` are deliberately kept separate from `_PROGRESS_MAP` to avoid breaking the existing orders-list float fractions while the tracking endpoint requires integer percentages.

**Security Check:**
- Verified `test_tracking_returns_404_for_other_accounts_order`: account B requesting account A's order ID returns `404`, not `403` — matches EC-UC7-01 enumeration prevention.
- Verified `test_tracking_404_for_other_account_does_not_leak_order_details`: the `404` response body does not contain account A's `order_id` or `account_id`.
- Verified `test_tracking_account_id_cannot_be_injected_via_query_param`: passing `?account_id=account_a` while authenticated as account B still returns `404`.

**Logic Fixes:**
- AI initially returned `int(progress * 100)` in `OrderTrackingSerializer.get_progress`, double-scaling values already in the `_TRACKING_PROGRESS_MAP`. Fixed by storing the map with integer values (0, 20, 50, 70, 90, 100) and returning them directly.
- AI aliased `out_for_delivery` to `"delivery"` only in `get_currentStatus` but not in `OrderTrackingHistorySerializer.get_status`. Fixed by applying the same alias in both methods so `test_history_out_for_delivery_label_is_delivery` passes.
- AI passed `history` directly as a positional argument to `OrderTrackingSerializer` instead of via `context`. Changed to `OrderTrackingSerializer(order, context={"history": history})` so `get_history` can access it as `self.context.get("history")`.
- AI initially placed `order_tracking` URL before `place/` in `urls.py`, causing the `<str:order_id>` path to capture `"place"` as an order ID. Fixed by ordering `""`, `"place/"`, then `"<str:order_id>/tracking/"`.
- Flutter `OrderTrackingModel.fromMap` initially parsed `progress` with `.toDouble()`, causing a type error since the entity declares `progress` as `int`. Fixed to use `(map['progress'] as num).toInt()`.
- `TrackingTimeline` foreground line width calculation divided by `stages.length` instead of `stages.length - 1`, causing the line to never reach the final stage. Fixed to divide by `(stages.length - 1 == 0 ? 1 : stages.length - 1)`.

---

### 4. Validation Table

| Test Case | Expected Outcome | Result (Pass/Fail) |
|---|---|---|
| `GET /api/order/{id}/tracking/` without token | `401 Unauthorized` | |
| `GET /api/order/{id}/tracking/` with invalid token | `401 Unauthorized` | |
| `GET /api/order/{id}/tracking/` for own order | `200 OK` | |
| Response contains all required fields | `orderId`, `currentStatus`, `progress`, `estimatedTimeMinutes`, `history` present | |
| `orderId` in response matches requested order | Equal to `order_a.order_id` | |
| `history` is a non-empty list after placement | At least 1 entry | |
| Each history entry has `status` and `timestamp` | Both keys present | |
| History sorted oldest-first | `timestamps == sorted(timestamps)` | |
| `currentStatus` for new PENDING order | `"pending"` (lowercase string) | |
| `currentStatus` for CONFIRMED | `"confirmed"` | |
| `currentStatus` for PREPARING | `"preparing"` | |
| `currentStatus` for READY | `"ready"` | |
| `currentStatus` for OUT_FOR_DELIVERY | `"delivery"` (alias, not raw) | |
| `currentStatus` for DELIVERED | `"delivered"` | |
| `progress` for PENDING | `0` | |
| `progress` for CONFIRMED | `20` | |
| `progress` for PREPARING | `50` | |
| `progress` for READY | `70` | |
| `progress` for OUT_FOR_DELIVERY | `90` | |
| `progress` for DELIVERED | `100` | |
| `progress` always in [0, 100] | Integer in valid range | |
| `estimatedTimeMinutes` is non-negative integer | `>= 0` | |
| `estimatedTimeMinutes` for DELIVERED | `0` | |
| ETA decreases monotonically through statuses | Each stage ETA ≥ next stage ETA | |
| Tracking for another account's order | `404 Not Found` (not 403) | |
| `404` response does not leak order or account IDs | Neither ID in response text | |
| `?account_id=other` query injection | `404 Not Found` | |
| Non-existent order ID | `404 Not Found` with `message` field | |
| `404` response does not expose internals | No traceback/exception/django/sql in body | |
| `POST` to tracking endpoint | `405 Method Not Allowed` | |
| `PUT` to tracking endpoint | `405 Method Not Allowed` | |
| `DELETE` to tracking endpoint | `405 Method Not Allowed` | |
| History for `OUT_FOR_DELIVERY` entry | Status label is `"delivery"`, not `"out_for_delivery"` | |
| All history status values | Lowercase strings only | |
| Multiple seeded history entries reflected | All entries appear in response history list | |