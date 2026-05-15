# Backend Apps Overview

This folder contains backend Django apps. The `cart` app is currently implemented and uses dummy menu data from `services.py`.

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

## Local Run

```bash
cd src/back
source /home/mar0/CSE/customer-ordering-system/.venv/bin/activate
python manage.py migrate
python manage.py runserver 127.0.0.1:8000
```

Login endpoint for session auth:

- `http://127.0.0.1:8000/api/auth/login/`

## Tests

```bash
cd src/back
source /home/mar0/CSE/customer-ordering-system/.venv/bin/activate
python manage.py check
python manage.py test apps.cart
```

## Notes

- Dummy menu records are in `apps/cart/services.py` under `DUMMY_MENU_ITEMS`.
- Price values are stored in pennies (`unit_price_snapshot`) to avoid float precision issues.
