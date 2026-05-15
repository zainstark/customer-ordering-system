# customer-ordering-system

A Django + Django REST Framework backend for a customer ordering system with a Flutter frontend.

## Features Implemented

### Menu Service (Feature: Menu)

Browse, search, and filter menu categories and items.

**Endpoint**
- `GET /menu/categories/` — Retrieve all active menu categories with available items

**Query Parameters**
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
- Requires session authentication (login required)
- Returns 403 Forbidden if not authenticated

**Example Requests**
```bash
# Browse all menu categories
curl -b cookies.txt http://127.0.0.1:8000/menu/categories/

# Search for pizza
curl -b cookies.txt "http://127.0.0.1:8000/menu/categories/?search=pizza"

# Filter by category
curl -b cookies.txt "http://127.0.0.1:8000/menu/categories/?category=Beverages"

# Combined search and filter
curl -b cookies.txt "http://127.0.0.1:8000/menu/categories/?search=coffee&category=Beverages"
```

## Project Structure

```
customer-ordering-system/
├── Docs/                          # Requirements, API contracts, ERD
├── src/
│   ├── back/                      # Django backend
│   │   ├── apps/menu/             # Menu service module (NEW)
│   │   │   ├── models.py          # MenuCatalog, MenuItem models
│   │   │   ├── serializers.py     # DRF serializers
│   │   │   ├── services.py        # Business logic
│   │   │   ├── views.py           # API views
│   │   │   ├── urls.py            # URL routing
│   │   │   ├── tests.py           # Test suite (13 tests)
│   │   │   └── migrations/        # Database migrations
│   │   ├── config/                # Django settings
│   │   ├── database/              # DB schema
│   │   └── manage.py
│   └── front/                     # Flutter frontend
└── README.md
```

## Setup & Running Locally

### Prerequisites
- Python 3.x
- Virtual environment (venv)

### Installation
```bash
cd src/back
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Database Setup
```bash
python manage.py migrate
```

### Running Tests
```bash
# Run menu service tests
python manage.py test apps.menu

# Run all tests
python manage.py test
```

### Starting the Development Server
```bash
python manage.py runserver
```

Visit `http://127.0.0.1:8000/admin/` to create a superuser and log in.

## Architecture

### Service Layer Pattern
- **models.py** — ORM models (MenuCatalog, MenuItem)
- **serializers.py** — Request/response validation and formatting
- **services.py** — Business logic (MenuService.get_catalogs)
- **views.py** — Thin views that call services
- **urls.py** — Route definitions

### Database Schema
- **menu_catalogs** — Menu category/catalog table
- **menu_items** — Individual menu items with references to catalogs

### Features
- Search items by name and description
- Filter catalogs by name
- Only active catalogs and available items are returned
- Price stored in pennies (integers) to avoid floating-point precision issues

## Testing

The Menu service includes comprehensive tests:
- **Model tests** — Catalog and item creation
- **Serializer tests** — Response formatting and API contract compliance
- **Service tests** — Business logic, search, filtering
- **API tests** — Endpoint access, authentication, query parameters
- **Edge cases** — Empty menu, no search results, unauthenticated access

Run: `python manage.py test apps.menu -v 2`

## Implementation Notes

- Session-based authentication (Django default)
- Price in API returned as float (dollars) but stored as integer (pennies)
- Items not available (available=False) are filtered out automatically
- Catalogs not active (active=False) are excluded from results
- Search is case-insensitive and matches partial strings