# Backend Apps Overview

This folder contains backend Django apps. The `cart` app and the `menu` app are currently implemented.

---

## Menu API Usage

Base prefix: `/menu/`

### Endpoints

- `GET /menu/categories/`
  - Returns all active menu catalogs with their available items.
  - Supports optional query parameters:
    - `search` — Filter items by name or description (case-insensitive substring match)
    - `category` — Filter catalogs by name (case-insensitive substring match)

**Response Format**
```json
[
  {
    "id": "cat1",
    "label": "Beverages",
    "menuItems": [
      {
        "id": "item1",
        "title": "Coffee",
        "subtitle": "Hot coffee",
        "unitPrice": 5.0,
        "imageUrl": "http://example.com/coffee.jpg"
      }
    ]
  }
]
```

**Authentication**
- Requires session authentication (login required).
- Returns `403 Forbidden` if not authenticated.

**Example Requests**
```bash
# Browse all menu categories
curl -b cookies.txt http://127.0.0.1:8000/menu/categories/

# Search for pizza
curl -b cookies.txt "http://127.0.0.1:8000/menu/categories/?search=pizza"

# Filter by category name
curl -b cookies.txt "http://127.0.0.1:8000/menu/categories/?category=Beverages"

# Combined search and category filter
curl -b cookies.txt "http://127.0.0.1:8000/menu/categories/?search=coffee&category=Beverages"
```

### Notes

- Only active catalogs (`active=True`) are returned.
- Only available items (`available=True`) are included within each catalog.
- Price is stored in pennies (`price_penny`) internally but returned as a float (dollars) in the API.
- Search is case-insensitive and matches partial strings against item name and description.

---

## Cart API Usage (legacy behavior)

Base prefix: `/api/cart/`

### Endpoints

- `GET /api/cart/?account_id=<ACCOUNT_ID>`
  - Returns the cart object with nested items.

- `POST /api/cart/items/`
  - Body:
    ```json
    {
      "account_id": "test_account_001",
      "menu_item_id": "menu_001",
      "quantity": 2
    }
    ```
  - Adds an item (or increments quantity if it already exists).

- `PATCH /api/cart/items/<cart_item_id>/`
  - Body:
    ```json
    {
      "quantity": 3
    }
    ```
  - Updates quantity for a cart item.

- `DELETE /api/cart/items/<cart_item_id>/delete/`
  - Removes one item from the cart.

- `POST /api/cart/validate/`
  - Body:
    ```json
    {
      "account_id": "test_account_001"
    }
    ```
  - Validates availability/pricing issues for cart items.

- `DELETE /api/cart/clear/`
  - Body:
    ```json
    {
      "account_id": "test_account_001"
    }
    ```
  - Clears all items from the account cart.

---

## Local Run

```bash
cd src/back
source /home/mar0/CSE/customer-ordering-system/.venv/bin/activate
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

Login endpoint for session auth:

- `http://127.0.0.1:8000/api/auth/login/`

---

## Tests

```bash
cd src/back
source /home/mar0/CSE/customer-ordering-system/.venv/bin/activate
python manage.py check

# Run menu tests
python manage.py test apps.menu

# Run cart tests
python manage.py test apps.cart

# Run all tests
python manage.py test
```

---

## Notes

- Dummy menu records for the cart app are in `apps/cart/services.py` under `DUMMY_MENU_ITEMS`.
- The menu app uses real database records managed via Django admin or migrations.
- Price values are stored in pennies (`unit_price_snapshot`, `price_penny`) to avoid float precision issues.