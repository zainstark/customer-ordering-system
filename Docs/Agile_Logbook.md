# 📖 Agile Logbook: Customer Ordering System

---

## 🏃‍♂️ Sprint 1: Menu, Cart, and Order

---

### 📱 Part 1: Menu UX & Data Consistency (Flutter Frontend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement:** Menu screens must be modular, reusable, and feature-first. Screens live in `presentation/screens`, reusable components in `presentation/widgets`, and the shared shell bar in `shell/presentation/widgets`.
* **Functional Requirement:** Menu UI must reflect the implemented domain models (`MenuCategoryEntity`, `MenuItemEntity`) and support item-level browsing with a detail view, quantity selection, and an Add-to-Cart entry point wired to `CartCubit`.
* **Non-Functional Requirement:** The app targets web first. Text must use `SelectableText` where appropriate. Layout must be responsive using `MediaQuery` breakpoints aligned with `app_dimensions.dart`. Theme tokens from `app_theme.dart` and `app_colors.dart` must be used consistently in both light and dark mode.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Initial Screen Structure + Component Build**
> **Role:** You are a senior Flutter UI engineer who builds scalable feature-first screens.  
> **Task:** Implement menu, cart, and orders presentation layers from the project's existing theme, dimension, and routing setup. Deliver `MenuScreen`, `CartScreen`, and `OrdersScreen` with their widget breakdowns — each screen in `presentation/screens`, each reusable piece in feature `presentation/widgets`.  
> **Context:** The project already has `app_theme.dart`, `app_colors.dart`, and `app_dimensions.dart`. The main router (`app_router.dart`) uses GoRouter with a `ShellRoute` for the shared navigation bar. The `Docs/` folder contains `ERD.md`, `UML Class Diagram.md`, and `Requirement and Use Cases.md` as structural references.  
> **Format:** Deliver a screen + widget breakdown per feature. Do not include backend logic or API calls — this phase is presentation only.  
> **Constraints & Examples:** Use `AppDimensions` constants for spacing and border radii. Use `Theme.of(context).colorScheme` for colors. Avoid hardcoded pixel values. Use a reusable item card widget for menu items rather than inline duplicated UI.

> **Prompt 2 — Feature Structure Enforcement**
> **Role:** You are a Flutter architect enforcing project conventions and maintainable composition.  
> **Task:** Reorganize presentation code so screens are in `presentation/screens`, reusable feature widgets are in `presentation/widgets`, and the shared app shell bar is centralized in `shell/presentation/widgets/app_shell_scaffold.dart`.  
> **Context:** Some UI parts were duplicated or placed in the wrong layer. The shell scaffold (top bar, bottom navigation) must be shared across all routes via GoRouter's `ShellRoute`.  
> **Format:** Provide a short "before vs after" file-location summary.  
> **Constraints & Examples:** Preserve behavior and visual design. Only move files — do not rewrite widget logic. Do not touch `Core/` files.

> **Prompt 3 — Menu Cubit State + Category Interaction**
> **Role:** You are a Flutter state-management engineer specializing in lightweight cubit interactions.  
> **Task:** Implement `MenuCubit` with dummy category data and a `selectCategory(String categoryId)` method. `MenuState` must hold a `List<MenuCategoryModel>` and a `selectedCategoryId`. `filteredDishes` must return the items for the selected category.  
> **Context:** At this stage the menu has no backend connection — it uses hardcoded `MenuCategoryModel` and `MenuItemModel` instances seeded directly in `MenuCubit`. The UI needs interactive category switching before full backend integration. `MenuCategoryModel` and `MenuItemModel` already exist in the data layer with `fromJson` constructors aligned to the backend schema.  
> **Format:** Show the cubit, state, and a brief description of the trigger → state update → rendered result flow.  
> **Constraints & Examples:** Keep state logic out of widgets. The cubit is registered as `registerFactory` in `injector.dart` so each route gets a fresh instance.

> **Prompt 4 — Menu UI Refinement + Item Detail Sheet**
> **Role:** You are a product-focused Flutter engineer refining UI to match real data model capabilities.  
> **Task:** Remove placeholder UI elements not backed by `MenuItemEntity` fields (star ratings, generic icon-only cards). Align `MenuFoodCard` rendering with `title`, `description`, `price`, `available`, and `imageUrl`. Add `MenuItemDetailsSheet` — a `Dialog` that opens on item tap and shows the item image, title, price, category, availability, a quantity stepper, and an "Add to Cart" button.  
> **Context:** `MenuItemEntity` has: `id`, `categoryId`, `title`, `description`, `price`, `available`, `rating`, `imageUrl`. The `rating` field exists in the model but is not surfaced in the backend `Docs/ERD.md` — do not display it until the backend supports it. The "Add to Cart" button in the sheet will be wired to `CartCubit` in the Cart Integration sprint.  
> **Format:** Summarize removals, additions, and the final user interaction flow: item tap → sheet open → quantity adjust → Add to Cart.  
> **Constraints & Examples:** Do not fabricate data fields. `SelectableText` must be used for any text the user might want to copy on web.

> **Prompt 5 — Web-Oriented Text + Image Loading**
> **Role:** You are a Flutter web UI engineer optimizing readability and media loading behavior.  
> **Task:** Replace static `Text` widgets in menu item cards and detail sheets with `SelectableText` for web usability. Implement `AppNetworkImage`, a shared widget that loads images from a URL with a consistent fallback placeholder (a container with a food icon) when the URL is missing or loading fails.  
> **Context:** The app targets web as its primary platform. Images come from `imageUrl` fields in `MenuItemEntity` and `CartItemEntity`. The fallback pattern must be consistent across menu cards, cart item cards, and order status cards.  
> **Format:** Provide a concise checklist of updated text behavior and the `AppNetworkImage` widget implementation.  
> **Constraints & Examples:** `AppNetworkImage` lives in `features/widgets/app_network_image.dart` as a shared cross-feature widget. Do not introduce multiple placeholder variants.

#### 3. Verification & Audit (The Human Bun)

**Model-to-UI Consistency Check:**
* `MenuFoodCard` and `MenuItemDetailsSheet` render only fields present in `MenuItemEntity` and confirmed in `Docs/ERD.md`.
* Star ratings and unsupported decorative elements were removed.

**Component Structure Check:**
* Screens in `presentation/screens`, widgets in `presentation/widgets`, shell scaffold in `shell/presentation/widgets`.
* `AppNetworkImage` lives in the shared `features/widgets/` folder and is reused across menu, cart, and orders.

**UX Flow Check:**
* Category selection updates `selectedCategoryId` in `MenuState` and re-renders `filteredDishes`.
* Item tap opens `MenuItemDetailsSheet` with quantity control and an Add-to-Cart entry point.
* Widget tests in `test/features/menu/` cover cubit category switching, state filtering, and widget rendering.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| Open menu screen | Categories and items render from `MenuCubit` dummy data | ✅ Pass |
| Select a menu category | `selectedCategoryId` updates; only that category's dishes appear | ✅ Pass |
| Tap menu item | `MenuItemDetailsSheet` opens with title, price, description, and quantity controls | ✅ Pass |
| Add to Cart button | Delegates to `CartCubit.addItem` (wired in Cart sprint) | ✅ Pass |
| Responsive breakpoints | Desktop shows sidebar + 3-column grid; tablet shows 2 columns; mobile shows 1 column | ✅ Pass |
| Selectable text on web | Item titles and descriptions are copyable | ✅ Pass |

---

### 🛒 Part 2: Cart Feature Implementation (Django REST Framework Backend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement (FR3):** The system shall allow an authenticated customer to add, update, remove, and view items in a persistent shopping cart, with a running total updated on every mutation.
* **Functional Requirement (FR4):** The cart must be validatable before order placement — checking item availability, menu item existence, and price consistency against the live menu.
* **Non-Functional Requirement (NFR 1 - Security):** All cart endpoints must be protected by JWT bearer token authentication. The account identity must be derived exclusively from the token payload — never from request body or query parameters. Cross-account cart item access must return `404 Not Found` (not `403`) to prevent resource enumeration.
* **Non-Functional Requirement (NFR 2 - Integrity):** Item quantities must never fall below 1. `line_total` and `cartTotal` must be computed server-side from stored price snapshots, never from client-supplied values. `clear_cart` must execute atomically.
* **Non-Functional Requirement (NFR 3 - Testability):** The menu lookup must be injectable via a provider seam (`CartService.set_menu_provider()`) so the service layer can be unit-tested without a populated `MenuItem` table.
* **Data Privacy:** Prices are stored and computed in pennies internally. The `unit_price_snapshot` raw integer is never exposed to clients — all monetary values are returned as dollar floats. No PII flows through any service method.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Feature Planning & Structure**
> I have made a new folder called `cart` in the `apps` directory. This folder should contain what is needed to implement the Django backend for the Cart feature. Make a solid plan on how to make it — I recommend making a file called `modules` (which will contain classes that come from the database), a file called `view` (that will contain the endpoints), and lastly a `services` file (that will contain the business logic and other service classes). You should also take note for using dummy data for now as the database is not populated yet.

> **Prompt 2 — Initial Implementation & Debugging**
> Everything seems to be working at least with the dummy data. I feel like `modules.py` is useless — can't we just do it all in the files that Django is expecting, which is `models.py`? Moreover, can you do a quick cleanup and remove what seems useless (not the dummy data and tests). Furthermore, can you read the `api-contract.md` that I attached and check if it matches our endpoints for the cart service only. If not, generate a new `api-contract.md` with our real endpoints for the frontend to use.

> **Prompt 3 — API Contract Compliance & Cleanup**
> Actually, can you use this file instead (`API_CONTRACT.md`) and try to make the `CartService` compliant with this contract? As well as the cleanup if possible in the plan. Make the plan first. You know what — make a plan to ditch the `API_CONTRACT`, and fall back to how the API worked previously. Remove any redundant comments, and I want the repo to work like how it was before the first `api_contract`. Also modify the README in the backend to have the actual usage of the feature.

> **Prompt 4 — Endpoint Sanity & URL Clarity**
> How can I get a cart if I don't have an ID for it? Can you make sure that all the endpoints can be called in a sensible way? Put a URL for each endpoint — it should be compatible with the API contract — and modify the comments to actually reflect the real URLs.
> * `GET /api/cart/` → `get_cart`
> * `POST /api/cart/items/` → `add_item_to_cart`
> * `PATCH /api/cart/items/{id}/` → `update_cart_item`
> * `DELETE /api/cart/items/{id}/` → `remove_item_from_cart`
> * `POST /api/cart/validate/` → `validate_cart`
> * `DELETE /api/cart/` → `clear_cart`

> **Prompt 5 — Auth Integration & Flutter Compatibility**
> Make a plan to update the cart to work with the current changes: use the current auth, take its models from `generated_models.py` (because this is what the database is expecting), and also make it usable with what the Flutter frontend is expecting. The tests with the dummy data should still work, and remember the only way to auth is the generated JWT token. Is the cart backend what Flutter is expecting? Did you use the new `generated_models.py` file for the cart models?

#### 3. Verification & Audit (The Human Bun)

**Dependency Audit:**
* All imports are from Django stdlib, DRF, or the existing project dependency `rest_framework_simplejwt`. No new packages were introduced.
* `DUMMY_MENU_ITEMS` in `services.py` is a temporary in-memory fixture, confirmed to be bypassed once the real `MenuItem` table is populated.

**Security Check:**
* Verified `test_get_cart_uses_token_account_not_query_account`: passing `?account_id=other_account` in the query string still returns the token holder's cart — account identity is read only from the JWT.
* PATCH and DELETE item views perform an explicit ownership check (`cart.account_id != account_id`) before calling the service, returning `404` on mismatch — confirmed this matches EC-UC3-02 (enumeration prevention).
* `unit_price_snapshot` is excluded from the serializer `fields` list; clients cannot read or influence the internal penny value.

**Logic Fixes:**
* AI used `menu_item.get('imageUrl')` only, missing the DB-sourced key `image_url`. Fixed with: `menu_item.get('image_url') or menu_item.get('imageUrl') or ''`.
* AI placed `line_total` computation only in `get_cart_total()` instead of persisting it in `save()`. Corrected so `line_total` is stored on every `CartItem.save()`.
* AI returned `HTTP_403_FORBIDDEN` on cart ownership mismatch. Changed to `HTTP_404_NOT_FOUND` per the enumeration-prevention requirement.
* AI called `RefreshToken.for_user(django_user)` in tests — incompatible with the custom `Accounts` model. Replaced with `RefreshToken()` and manual claim injection.
* AI omitted `_ensure_accounts_table()` in test setup, causing `OperationalError: no such table: accounts` for the unmanaged auth model. Fixed by calling it inside `setUpClass` of each test case.
* Migration failed with `non-nullable field 'account'` error after models were updated. Resolved by deleting stale migrations and regenerating them cleanly.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| `GET /api/cart/` without token | `401 Unauthorized` | ✅ Pass |
| `GET /api/cart/` with valid token | `200 OK`, `accountId` matches token | ✅ Pass |
| `GET /api/cart/` with `?account_id` of another user | Returns token holder's cart, not the other account's | ✅ Pass |
| `POST /api/cart/items/` with `quantity=0` | `400 Bad Request`, validation error | ✅ Pass |
| `POST /api/cart/items/` with unknown `menu_item_id` | `400`, `"Menu item … not found"` | ✅ Pass |
| `POST /api/cart/items/` with unavailable item | `400`, `"… is out of stock"` | ✅ Pass |
| `POST /api/cart/items/` success — response shape | Keys: `id`, `cartId`, `menuItemId`, `title`, `subtitle`, `unitPrice`, `quantity`, `imageUrl` | ✅ Pass |
| `POST /api/cart/items/` — `unitPrice` for 1599-penny item | `15.99` (float) | ✅ Pass |
| `PATCH /api/cart/items/{id}/` (other account's cart) | `404 Not Found` | ✅ Pass |
| `DELETE /api/cart/items/{id}/delete/` (other account's cart) | `404 Not Found` | ✅ Pass |
| `CartItem.save()` with `qty=3`, `unit_price_snapshot=500` | `line_total == 1500` | ✅ Pass |
| Add same menu item to cart twice | Quantity accumulates, single `CartItem` row | ✅ Pass |
| `validate_cart_items` — price changed since addition | `is_valid: false`, `"Price has changed"` in issues | ✅ Pass |
| `validate_cart_items` — all items current | `is_valid: true`, `issues: []` | ✅ Pass |

---

### 🔗 Part 3: Cart Integration Alignment (Flutter Frontend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement:** The Cart API integration must match `Docs/cart_API_CONTRACT.md` exactly — endpoints, HTTP methods, request payloads, query parameters, and response field names.
* **Functional Requirement:** Cart actions must be wired end-to-end: the "Add to Cart" button in `MenuItemDetailsSheet` must call `CartCubit.addItem`, and the trash icon in `CartItemCard` must call `CartCubit.removeItem`.
* **Non-Functional Requirement:** No UI, widget, screen, or backend file may be modified. Only Cart data/domain layers and DI wiring are in scope.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Contract-First Mismatch Analysis**
> **Role:** You are a senior Flutter engineer with deep experience in Clean Architecture and API contract integration.  
> **Task:** Compare the current Cart implementation against `Docs/cart_API_CONTRACT.md`. List every mismatch before touching any code: wrong endpoints, wrong HTTP methods, wrong request body fields, wrong response field names, missing auth handling.  
> **Context:** The backend is already working. The cart contract defines these operations: `GET /api/cart/` (by `account_id` query param), `POST /api/cart/items/` (body: `account_id`, `menu_item_id`, `quantity`), `PATCH /api/cart/items/<cart_item_id>/` (body: `quantity`), `DELETE /api/cart/items/<cart_item_id>/delete/`. The response from the cart is a `Cart` object with nested `items`.  
> **Format:** Return a mismatch report first (endpoint by endpoint), then list what files will change and why.

> **Prompt 2 — API Endpoints, Datasource, and Response Parsing Fix**
> **Role:** You are a senior Flutter integration engineer fixing Cart datasource compliance.  
> **Task:** Update `CartRemoteDataSource` to use the exact endpoints and HTTP methods from `cart_API_CONTRACT.md`. Add a `patch()` method to `DioClient`. Update `CartItemModel.fromMap()` to parse the backend's snake_case field names. Update `ApiEndpoints` with the correct cart paths.  
> **Context:** The current datasource uses wrong paths (`/carts/{cartId}`) and wrong HTTP methods (PUT instead of PATCH). The backend stores prices in pennies (`unit_price_snapshot`); the model must convert to a `double` for display.  
> **Format:** Show each changed file path, what changed, and the complete updated code.

> **Prompt 3 — Cubit & Add-to-Cart Menu Wiring**
> **Role:** You are a Flutter feature-integration specialist focused on state management and request flow wiring.  
> **Task:** Wire the "Add to Cart" button in `MenuItemDetailsSheet` to `CartCubit.addItem`. The `addItem` method must call `AddCartItemUseCase`, which calls `CartRepository.addItem`, which calls `CartRemoteDataSource.addItem` with `POST /api/cart/items/`.  
> **Context:** `MenuItemDetailsSheet` already has an `ElevatedButton` with `onPressed: () {}`. It has access to the menu item's `id` and the selected `quantity`.  
> **Format:** Show the cubit method, use case, repository contract update, datasource implementation, and the minimal widget change needed to call `context.read<CartCubit>().addItem()`.

> **Prompt 4 — Cart Delete Action Wiring**
> **Role:** You are a senior Flutter engineer responsible for interaction-to-API wiring.  
> **Task:** Wire the trash icon in `CartItemCard` to `CartCubit.removeItem`.  
> **Context:** `CartItemCard` already has an `IconButton` with `Icons.delete_outline` and `onPressed: () {}`.  
> **Format:** Show the updated `CartItemCard`, the `removeItem` method in `CartCubit`, and the datasource implementation.

#### 3. Verification & Audit (The Human Bun)

**Contract Compliance Check:**
* All endpoints, HTTP methods, query params, and body fields match `Docs/cart_API_CONTRACT.md`.
* `CartItemModel.fromMap()` parses `cart_item_id`, `unit_price_snapshot` (pennies to double), `menu_item_name`, and `menu_item_description` from the backend response.

**Integration Integrity Check:**
* "Add to Cart" in `MenuItemDetailsSheet` calls `CartCubit.addItem`.
* Trash icon in `CartItemCard` calls `CartCubit.removeItem`.
* Increment/decrement uses `PATCH /api/cart/items/<id>/` with a `quantity` body.

**Scope & Safety Check:**
* No backend file was modified.
* No screen, layout, or styling was changed outside the minimal `onPressed` wires.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| Get cart by account ID | `GET /api/cart/?account_id=<id>` returns cart with nested items | ✅ Pass |
| Add item from menu to cart | `POST /api/cart/items/` creates item; cart state updates | ✅ Pass |
| Delete item via trash icon | `DELETE /api/cart/items/<id>/delete/` removes item | ✅ Pass |
| Update quantity (increment/decrement) | `PATCH /api/cart/items/<id>/` with new quantity | ✅ Pass |
| Pennies-to-dollars conversion | `unit_price_snapshot` (e.g. 1500) renders as `$15.00` in UI | ✅ Pass |
| Non-cart feature stability | Menu, orders, and payment features unaffected | ✅ Pass |

---

### 📦 Part 4: Place Order (UC4) (Django REST Framework + Flutter Frontend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement (FR4):** The system shall allow an authenticated customer to convert their active cart into a confirmed order by submitting a delivery address. The order must be assigned a unique ID and set to status `PENDING` upon creation.
* **Functional Requirement (FR3 — dependency):** The cart must be non-empty and all items must still be available at the time of order placement.
* **Non-Functional Requirement (NFR 1 — Security):** All order endpoints must be protected by JWT bearer token authentication. The `account_id` must be derived exclusively from the token payload — never from the request body or query parameters.
* **Non-Functional Requirement (NFR 2 — Integrity):** The order total must be computed exclusively from live database prices, never from cart price snapshots. All order creation steps must execute inside a single atomic transaction. The cart must be preserved on failure.
* **Non-Functional Requirement (NFR 3 — Idempotency):** A 30-second idempotency window must prevent duplicate orders from double-click or network retry scenarios (EC-UC4-02).

#### 2. Implementation (The AI Meat)

> **Prompt 1 — TDD: Write Tests First for the Order Service**
> Write the unit tests for the `OrderService.place_order` method before implementing it. The tests should cover: placing a valid order returns an Order object with status PENDING, the total is computed in pennies from live DB prices, order items are created with snapshots, the cart is cleared after success, an empty cart returns an error without creating any DB rows, a missing cart returns an error, an unavailable item returns an error, a mixed available/unavailable cart fails atomically, and the 30-second idempotency window returns the same order on a duplicate submit.

> **Prompt 2 — TDD: Write Tests First for the Order API Endpoints**
> Now write the API-level tests for `POST /api/order/place/` and `GET /api/order/` before implementing the views. Cover all authentication guards, response shaping, validation messaging, and idempotency logic.

> **Prompt 3 — Implement the Order Models**
> Implement `apps/order/models.py` with the `Orders`, `OrderItems`, and `OrderStatusHistory` models to match the ERD. `Orders` should have `order_id` (UUID PK), `account`, `total_amount` (int pennies), `placed_at`, `order_status`, `confirmed_at`, `updated_at`, and `address`. `OrderItems` should snapshot `item_name_snapshot`, `item_description_snapshot`, `unit_price_snapshot`, `quantity`, and auto-compute `line_total` in `save()`. Make sure migrations are generated cleanly.

> **Prompt 4 — Implement the Order Service**
> Now implement `apps/order/services.py` with `OrderService.place_order(account_id, address)` and `OrderService.get_orders_for_account(account_id)`. Follow the 10-step atomic transaction logic defined in tests. Run the tests — all must pass.

> **Prompt 5 — Implement Serializers**
> Implement `apps/order/serializers.py` converting pennies to dollars and mapping statuses to progress floats (`_PROGRESS_MAP`). Match the Flutter `OrderItemModel.fromMap` field names exactly.

> **Prompt 6 — Implement Views and URLs**
> Implement `apps/order/views.py` with `list_orders` (GET) and `place_order` (POST). Add `apps/order/urls.py`. Wire into `config/urls.py` at `api/order/`. Re-run all order tests — they must all pass.

#### 3. Verification & Audit (The Human Bun)

**Dependency Audit:**
* All backend imports are from Django stdlib, DRF, or `rest_framework_simplejwt`.
* `transaction.atomic()` is used correctly.

**Security Check:**
* Verified `test_place_order_uses_account_from_token_not_body`: passing `account_id` in the request body still creates the order under the authenticated account.
* Verified `test_list_orders_account_id_comes_from_token`: passing `?account_id=` as a query parameter still returns only the authenticated account's orders.

**Logic Fixes:**
* AI initially computed `total_amount` from `cart_item.unit_price_snapshot`. Fixed to use `cart_item.menu_item.price_penny` (live DB price).
* AI placed cart-clearing before availability validation. Fixed by moving `CartService.clear_cart()` inside the successful atomic block.
* AI omitted `_ensure_accounts_table()` in `setUpClass`. Fixed by calling it in every `TestCase.setUpClass`.
* AI forgot to seed `OrderStatusHistory` after order creation. Added `OrderStatusHistory.objects.create(...)`.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| `POST /api/order/place/` without token | `401 Unauthorized` | ✅ Pass |
| `POST /api/order/place/` with invalid/inactive token | `401 Unauthorized` | ✅ Pass |
| `POST /api/order/place/` with valid cart | `201 Created`, `status = PENDING` | ✅ Pass |
| Response has all required fields | `orderId`, `accountId`, `status`, `placedAt`, `totalAmount`, `progress`, `items` present | ✅ Pass |
| `totalAmount` for 2×£10.00 items | `20.00` (float dollars) | ✅ Pass |
| `progress` for PENDING order | `0.1` (float in [0.0, 1.0]) | ✅ Pass |
| `accountId` in response | Matches token, not request body | ✅ Pass |
| Request body contains `account_id` of another user | Order still created under token account | ✅ Pass |
| Cart is cleared after successful placement | `CartItem` count = 0 | ✅ Pass |
| `POST /api/order/place/` with empty cart | `400 Bad Request`, message contains "empty" | ✅ Pass |
| `POST /api/order/place/` with unavailable item | `400 Bad Request`, item name in error message | ✅ Pass |
| Cart preserved when item is unavailable | `CartItem` count unchanged | ✅ Pass |
| `POST /api/order/place/` missing address | `400 Bad Request` | ✅ Pass |
| Total computed from live DB price, not snapshot | `totalAmount` reflects `price_penny` | ✅ Pass |
| Duplicate submit within 30 seconds | Same `orderId` returned, only 1 order row in DB | ✅ Pass |
| Mixed available/unavailable items in cart | No DB rows created (atomic rollback) | ✅ Pass |
| `OrderStatusHistory` seeded on placement | At least 1 history row with status PENDING | ✅ Pass |
| `GET /api/order/` without token | `401 Unauthorized` | ✅ Pass |
| `GET /api/order/` returns only own orders | Other account's orders excluded | ✅ Pass |
| `GET /api/order/` returns newest first | `placedAt` descending | ✅ Pass |
| `?account_id=other` query param in list | Ignored — returns token holder's orders only | ✅ Pass |

---

### 📋 Part 5: Orders Contract Integration (Flutter Frontend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement:** The Orders frontend integration must match `Docs/order_API_CONTRACT.md` exactly — endpoints, HTTP methods, request/response field names, and authentication handling.
* **Functional Requirement:** The "Proceed to Checkout" button in `CartOrderSummaryCard` must create an order via `POST /api/orders/` and store the returned `order_id` in `OrdersCubit` state so it can be passed to the payment screen.
* **Non-Functional Requirement:** No UI, widget, screen layout, or backend file may be modified. Only Orders data/domain layers and cubit integration are in scope.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Contract-Accurate Orders Integration**
> **Role:** You are a senior Flutter integration engineer focused on contract-accurate feature delivery.  
> **Task:** Compare the current `OrdersRemoteDataSource`, `OrdersRepositoryImpl`, and `OrdersCubit` against `Docs/order_API_CONTRACT.md`. Identify every mismatch and fix the integration layer only.

> **Prompt 2 — Create Order + Pending State + Payment Handoff**
> **Role:** You are a Flutter domain-flow engineer ensuring lifecycle correctness.  
> **Task:** Add a `createOrder(String accountId)` method to `OrdersCubit` that calls `CreateOrderUseCase`, which calls `POST /api/orders/`. On success, store the returned `order_id` in `OrdersState` as `pendingOrderId`. Emit an `OrdersRequestStatus.success` state. Leave a `// TODO: navigate to payment screen` comment.

> **Prompt 3 — Orders Screen Data Cleanup**
> **Role:** You are a senior Flutter product engineer aligning screens with real backend capabilities.  
> **Task:** Update `OrdersMainColumn` and `OrderStatusCard` to render data from `OrderItemEntity` fields only. Remove any placeholder elements not backed by the API contract (reward banners, points, non-functional "Track" buttons).

> **Prompt 4 — Readable Order Presentation**
> **Role:** You are a UX-oriented Flutter engineer improving data readability without redesigning.  
> **Task:** Replace raw technical identifiers in `OrderStatusCard` with human-readable labels. Show `Order #<orderId>` instead of the raw UUID. Show the formatted `placedAt` date. Show `$<totalAmount>` with two decimal places.

> **Prompt 5 — Test Alignment**
> **Role:** You are a Flutter testing engineer keeping tests aligned with the current integration state.  
> **Task:** Update `OrdersCubit` unit tests in `test/features/orders/` to cover: `loadOrders` success, `loadOrders` error state, tab switching, and `createOrder`.

#### 3. Verification & Audit (The Human Bun)

**Contract Compliance Check:**
* `GET /api/orders/?account_id=<id>` and `POST /api/orders/` match `Docs/order_API_CONTRACT.md`.
* Active/past order split is based on `order_status` values.

**Checkout Continuity Check:**
* "Proceed to Checkout" creates an order and stores `pendingOrderId` in `OrdersState`.

**UI Purpose Check:**
* Reward banners, points, and non-functional tracking controls removed.
* All remaining displayed data comes from `OrderItemEntity` fields backed by the API contract.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| Proceed to checkout | Order is created and order ID is retained | ✅ Pass |
| New order status before payment | Status appears as pending | ✅ Pass |
| Orders screen data rendering | API-backed data is shown in readable format | ✅ Pass |
| Removed non-functional elements | Reward/points/unused controls no longer appear | ✅ Pass |
| Widget test for app flow | Tests compile and run with current route/import setup | ✅ Pass |

---

## 💳 Sprint 2: Authentication and Payment

---

### 🔐 Part 1: Authentication Feature Implementation

#### 1. Specification (The Architect Bun)

* **Functional Requirement (FR1):** The system shall allow a customer to register and log in using an email and password. Upon successful authentication, the system shall issue a JWT bearer token representing the authenticated account identity.
* **Non-Functional Requirement (NFR 1 - Performance):** Authentication endpoints (`register` and `login`) must respond within **≤ 2 seconds** under normal operating conditions.
* **Non-Functional Requirement (NFR 2 - Security):** All authenticated endpoints must be protected using JWT bearer token authentication. Account identity must be derived exclusively from the token payload. Passwords must be securely hashed. Authentication attempts exceeding the allowed threshold must trigger a temporary account lockout.
* **Data Privacy:** User passwords must be securely **hashed before storage** and must never be stored, transmitted, or returned in plaintext.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Feature Planning & Structure**
> I am working on a university project that's essentially a resturant app that allows you to browse and order food. We use vertical slicing... I want you to plan now how should I write the authentication feature. Note that I use my own table for Accounts inside the Database, and don’t use django_auth.

> **Prompt 2 — Initial Implementation & Debugging**
> ... The problem however is this `token_blacklist.OutstandingToken.user: (fields.E300) Field defines a relation with model 'auth.User'...` these depends on django.auth and I simply don't use it, is there a way to solve this without downloading django auth and ignoring it?

> **Prompt 3 — UI Implementation**
> I want to implement this html code (index.html) in flutter. I want you to use app_themes and app_dimensions. Also make it responsive, and integrate it with the back end...

> **Prompt 4 — Refresh token behaviour debugging**
> The system works fine with itself. However, a problem that arose is that when the access token expires and use is not granted another access token via the refresh token, but rather he is trapped inside the website with no access... I want you to give me a comprehensive analysis as to what could be the issue causing this.

> **Prompt 5 — Access token behaviour debugging**
> Great now the use is not trapped inside anymore, and when the token expires he is instead redirected automatically to the login page. However, when he logs in he is again redirected to the login page infinitly. SO instead of being trapped inside, he is now trapped outside.

#### 3. Verification & Audit (The Human Bun)

**Dependency Audit**
No new packages introduced. Backend uses only `django.contrib.auth.hashers`, `rest_framework`, `rest_framework_simplejwt`, and `django.core.cache`. Frontend uses existing dependencies.

**Security Check**
* **JWT identity is never read from query parameters.**
* **Public/protected endpoint separation is enforced at the interceptor level.**
* **Brute-force protection is implemented.**
* **Passwords are hashed with `make_password` / `check_password`.**
* **Disabled accounts are rejected at two layers.**
* **API responses expose only the JWT.**
* **Token storage is platform-appropriate.**

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| POST `/auth/register/` with valid data | `201 Created`, returns access token | ✅ Pass |
| POST `/auth/register/` with duplicate email | `400 Bad Request`, `"Email already in use"` | ✅ Pass |
| POST `/auth/register/` with password < 8 chars | `400 Bad Request`, validation error | ✅ Pass |
| POST `/auth/register/` without required fields | `400 Bad Request`, validation error | ✅ Pass |
| POST `/auth/register/` success — password storage | Password stored hashed, not plaintext | ✅ Pass |
| POST `/auth/register/` success — default account role | Account role set to `"customer"` | ✅ Pass |
| POST `/auth/register/` success — active flag | Account created with `active = true` | ✅ Pass |
| POST `/auth/login/` with valid credentials | `200 OK`, returns access token | ✅ Pass |
| POST `/auth/login/` with wrong password | `401 Unauthorized`, `"Invalid email or password"` | ✅ Pass |
| POST `/auth/login/` with unknown email | `401 Unauthorized`, `"Invalid email or password"` | ✅ Pass |
| POST `/auth/login/` for disabled account | `401 Unauthorized`, `"Account is disabled"` | ✅ Pass |
| POST `/auth/login/` after 5 failed attempts | `401 Unauthorized`, account locked | ✅ Pass |
| POST `/auth/login/` during lockout period | `401 Unauthorized`, lockout message | ✅ Pass |
| POST `/auth/login/` after lockout expires | Login succeeds with valid credentials | ✅ Pass |
| POST `/auth/login/` successful after failed attempts| Failed-attempt counter resets | ✅ Pass |
| Access protected endpoint without token | `401 Unauthorized` | ✅ Pass |
| Access protected endpoint with invalid/expired token| `401 Unauthorized`, `"Invalid or expired token"` | ✅ Pass |
| Access protected endpoint with valid token | `200 OK`, authenticated user returned | ✅ Pass |
| Access protected endpoint with token for deleted account| `401 Unauthorized`, `"Account not found"` | ✅ Pass |
| Access protected endpoint with disabled account token | `401 Unauthorized`, `"Account is disabled"` | ✅ Pass |
| JWT token payload after login | Contains `account_id`, `email`, `role`, `display_name` | ✅ Pass |

---

### 🏦 Part 2: Payment Backend Rollout (Django Backend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement:** Implement Stripe PaymentIntent flow in a new `payments` Django app, with order-linked payment records and contract-aligned responses.
* **Functional Requirement:** Payment creation must validate order ownership, compute amount server-side from DB order totals, and return `client_secret` and `payment_intent_id` for the Flutter Stripe SDK.
* **Non-Functional Requirement:** Use environment-variable key management, idempotency safeguards, and atomic transaction-safe updates while preserving the existing backend architecture style.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Production-Grade Payment Build**
> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Implement a production-grade Stripe PaymentIntent workflow in the existing Django backend, following the architecture of the `cart` and `order` apps exactly...

> **Prompt 2 — Migration and Test Recovery**
> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Diagnose and fix all migration and test failures introduced during the payment rollout...

> **Prompt 3 — Authorization Header Parity**
> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Update all payment views to match the cart app's bearer-token authentication pattern exactly...

> **Prompt 4 — Contract Synchronization**
> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Update `Docs/checkout_API_CONTRACT.md` to accurately reflect the current backend implementation...

> **Prompt 5 — Workflow Documentation**
> **Role:** You are a senior backend engineer specialized in Django, Stripe, API integrations, testing, and clean architecture.
> **Task:** Write `Docs/checkout_payment_workflow.md` — a step-by-step markdown guide documenting the exact end-to-end payment lifecycle for the team...

#### 3. Verification & Audit (The Human Bun)

**Security & Integrity Check:**
* Amount is calculated from DB order totals; no client-provided amount is trusted.
* Auth and ownership validation are required before payment intent creation.
* Stripe keys are loaded from environment variables only; none are hardcoded.

**Stripe Flow Check:**
* Backend creates and stores `Payment` and `PaymentTransaction` records tied to the order.
* `client_secret` and `payment_intent_id` are returned for the Flutter Stripe SDK to consume.
* Webhook signature verification uses `STRIPE_WEBHOOK_SECRET` before any status updates.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| Create payment intent for valid order | Returns `client_secret`, `payment_intent_id`, and `payment_id` | ✅ Pass |
| Create payment intent with invalid ownership | Request is rejected with 403/404 | ✅ Pass |
| Amount calculation source | Uses DB order totals, not client input | ✅ Pass |
| Duplicate payment prevention | Idempotency safeguard blocks a second intent for the same order | ✅ Pass |
| Auth header handling | Bearer-token pattern matches cart and order protected endpoints | ✅ Pass |
| Webhook signature verification | Invalid signature returns 400; valid signature updates payment and order status | ✅ Pass |
| Migration on existing DB | `--fake-initial` applies `payments` migrations cleanly without conflict | ✅ Pass |
| Full test suite | All 72 tests across cart, order, and payments pass | ✅ Pass |

---

### 💳 Part 3: Payment Feature Implementation (Frontend)

#### 1. Specification (The Architect Bun)

* **Functional Requirement:** Replace all dummy/mock checkout and payment logic in the Flutter frontend with real Cubit-driven state management, fully orchestrated against the implemented backend payment system.
* **Functional Requirement:** The checkout flow must derive from the real `CartCubit` state, enforce backend-aligned validation, support the full payment lifecycle, and handle all documented edge cases.
* **Non-Functional Requirement:** Preserve the existing Cubit architecture, dependency injection patterns, repository/service abstractions, and UI design. Follow TDD conventions.

#### 2. Implementation Highlights

* **Iteration 1:** Architecture Discovery & Integration Planning
* **Iteration 2:** Core Integration Implementation
* **Iteration 3:** Test-Driven Verification (TDD)
* **Iteration 4:** Payment Architecture Audit & State Machine Correction
* **Iteration 5:** Backend & Frontend Alignment Fixes
* **Iteration 6:** Compilation Error: Missing `clientSecret` Field
* **Iteration 7:** Stripe SDK Platform Correction
* **Iteration 8:** Full Stripe API Migration (TDD Re-verification)

#### 3. Verification & Audit (The Human Bun)

**State Machine Correctness:**
* `CheckoutCubit` correctly walks `validatingCart → creatingOrder → creatingPaymentIntent → awaitingPayment → success/failure` with no skipped transitions.
* Polling correctly detects uppercase `COMPLETED`, `FAILED`, and `CANCELLED` statuses matching backend contracts.
* Retry flow resets order to `PENDING` server-side before re-attempting.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| Successful checkout orchestration (CARD) | Emits full state sequence through to `success` | ✅ Pass |
| Cart validation failure | `failure` state emitted with backend error message | ✅ Pass |
| Payment failure and retry | `failure` → retry → re-enters `creatingPaymentIntent` | ✅ Pass |
| CASH payment — no Stripe call | Backend short-circuits; order confirmed without `PaymentSheet` | ✅ Pass |
| Double-click / duplicate submission | Guard in `create_payment_session` rejects if order not `PENDING`/`FAILED` | ✅ Pass |
| Polling status normalization | Uppercase `COMPLETED` / `FAILED` correctly terminates polling loop | ✅ Pass |
| `clientSecret` propagation | Field parsed from API → model → entity → cubit → `PaymentSheet` without compilation error | ✅ Pass |
| Stripe SDK initialization (Web) | `Stripe.js` loaded in HTML head; `StripeService.init()` runs before `runApp()` | ✅ Pass |
| `flutter analyze` post-migration | No warnings or errors | ✅ Pass |
| Pre-existing widget tests | Documented as pre-existing failures; scoped out of this sprint | ⚠️ Out of Scope |

---

## 🔔 Sprint 3: Notifications and Order Tracking

---

### 📨 Part 1: Notifications Feature Implementation

#### 1. Specification (The Architect Bun)

* **Functional Requirement (FR7):** The system shall send order confirmation notifications to authenticated customers after successful order placement and payment confirmation.
* **Functional Requirement (FR8):** The system shall update customers with order status notifications throughout the order lifecycle.
* **Functional Requirement (FR9):** The customer shall be able to track notifications and order status updates from the frontend notification center.
* **Non-Functional Requirement (NFR1):** Notification endpoints and status retrieval operations must respond within ≤ 2 seconds.
* **Non-Functional Requirement (NFR3):** All notification-related communication and API endpoints must use secure HTTPS and JWT authentication.

#### 2. Implementation (The AI Meat)

> **Prompt 1 — Frontend Notifications Architecture**
> You are implementing a Notifications feature in an existing Flutter application. Follow the current project architecture exactly.

> **Prompt 2 — Remove Frontend Dummy Data**
> can you check for the notification feature in the front end? i want you to remove all the dummy data for it.

> **Prompt 3 — Backend Notifications Feature with Tests**
> I want to implement the back for the notification feature. I attached generated models file, that you should use to make a models.py for the backend...

> **Prompt 4 — TDD Failure Phase**
> The notification serializer tests are failing. Check why the serializer output does not match the frontend expectations and fix the API response structure and timestamp formatting.

> **Prompt 5 — TDD Success Phase**
> Run the full notification test suite again and verify that the notification endpoints, serializers, unread counts, and mark-as-read flows all work correctly with JWT authentication and pagination.

#### 3. Verification & Audit (The Human Bun)

**Dependency Audit**
The notification implementation reused existing project dependencies and architecture patterns.

**Backend Verification**
The backend notification feature was validated through automated test execution covering API endpoints, Notification Model Behavior, and Notification Service Logic. All 24 tests passed successfully.

---

### 📍 Part 2: Order Tracking Feature

#### 1. Specification (The Architect Bun)

* **Functional Requirement (FR9):** The system shall allow an authenticated customer to retrieve the current tracking status of their order, including a progress value, an estimated time remaining in minutes, and a chronological history of all status changes.
* **Functional Requirement (FR8):** The system shall record every order status change in `OrderStatusHistory`, enabling a full timeline to be surfaced to the customer.
* **Non-Functional Requirement (NFR 1 — Security):** The tracking endpoint must enforce customer-level authorization.
* **Non-Functional Requirement (NFR 2 — Contract Compliance):** The API response must conform to `tracking_API_CONTRACT.md`.
* **Non-Functional Requirement (NFR 3 — Read-Only):** The tracking endpoint is strictly read-only (`GET` only).

#### 2. Implementation (The AI Meat)

> **Prompt 1 — TDD: Write Tests First for the Tracking Service**
> Write the unit tests for `OrderService.get_order_tracking(order_id, account_id)` before implementing it.

> **Prompt 2 — TDD: Write Tests First for the Tracking API**
> Write the full API test suite for `GET /api/order/{orderId}/tracking/` before implementing it.

> **Prompt 3 — Implement the Tracking Service Method**
> Add `OrderService.get_order_tracking(order_id, account_id)` to `apps/order/services.py`.

> **Prompt 4 — Implement the Tracking Serializers**
> Add `OrderTrackingHistorySerializer` and `OrderTrackingSerializer` to `apps/order/serializers.py`.

> **Prompt 5 — Implement the Tracking View and URL**
> Add `order_tracking(request, order_id)` to `apps/order/views.py`.

> **Prompt 6 — Wire the Flutter Frontend**
> On the Flutter side, implement `OrderTrackingEntity` and `TrackingHistoryEntry` domain entities...

> **Prompt 7 — Implement the TrackingTimeline Widget**
> Implement the `TrackingTimeline` widget using an enum `OrderTrackingStage`...

#### 3. Verification & Audit (The Human Bun)

**Security Check:**
* Verified `test_tracking_returns_404_for_other_accounts_order` and `test_tracking_404_for_other_account_does_not_leak_order_details`.
* Verified `test_tracking_account_id_cannot_be_injected_via_query_param`.

#### 4. Validation Table

| Test Case | Expected Outcome | Result |
| :--- | :--- | :--- |
| `GET /api/order/{id}/tracking/` without token | `401 Unauthorized` | ✅ Pass |
| `GET /api/order/{id}/tracking/` with invalid token | `401 Unauthorized` | ✅ Pass |
| `GET /api/order/{id}/tracking/` for own order | `200 OK` | ✅ Pass |
| Response contains all required fields | `orderId`, `currentStatus`, `progress`, `estimatedTimeMinutes`, `history` present | ✅ Pass |
| `orderId` in response matches requested order | Equal to `order_a.order_id` | ✅ Pass |
| `history` is a non-empty list after placement | At least 1 entry | ✅ Pass |
| Each history entry has `status` and `timestamp` | Both keys present | ✅ Pass |
| History sorted oldest-first | `timestamps == sorted(timestamps)` | ✅ Pass |
| `currentStatus` for new PENDING order | `"pending"` (lowercase string) | ✅ Pass |
| `currentStatus` for CONFIRMED | `"confirmed"` | ✅ Pass |
| `currentStatus` for PREPARING | `"preparing"` | ✅ Pass |
| `currentStatus` for READY | `"ready"` | ✅ Pass |
| `currentStatus` for OUT_FOR_DELIVERY | `"delivery"` (alias, not raw) | ✅ Pass |
| `currentStatus` for DELIVERED | `"delivered"` | ✅ Pass |
| `progress` for PENDING | `0` | ✅ Pass |
| `progress` for CONFIRMED | `20` | ✅ Pass |
| `progress` for PREPARING | `50` | ✅ Pass |
| `progress` for READY | `70` | ✅ Pass |
| `progress` for OUT_FOR_DELIVERY | `90` | ✅ Pass |
| `progress` for DELIVERED | `100` | ✅ Pass |
| `progress` always in [0, 100] | Integer in valid range | ✅ Pass |
| `estimatedTimeMinutes` is non-negative integer | `>= 0` | ✅ Pass |
| `estimatedTimeMinutes` for DELIVERED | `0` | ✅ Pass |
| ETA decreases monotonically through statuses | Each stage ETA ≥ next stage ETA | ✅ Pass |
| Tracking for another account's order | `404 Not Found` (not 403) | ✅ Pass |
| `404` response does not leak order or account IDs | Neither ID in response text | ✅ Pass |
| `?account_id=other` query injection | `404 Not Found` | ✅ Pass |
| Non-existent order ID | `404 Not Found` with `message` field | ✅ Pass |
| `404` response does not expose internals | No traceback/exception/django/sql in body | ✅ Pass |
| `POST` to tracking endpoint | `405 Method Not Allowed` | ✅ Pass |
| `PUT` to tracking endpoint | `405 Method Not Allowed` | ✅ Pass |
| `DELETE` to tracking endpoint | `405 Method Not Allowed` | ✅ Pass |
| History for `OUT_FOR_DELIVERY` entry | Status label is `"delivery"`, not `"out_for_delivery"` | ✅ Pass |
| All history status values | Lowercase strings only | ✅ Pass |
| Multiple seeded history entries reflected | All entries appear in response history list | ✅ Pass |
