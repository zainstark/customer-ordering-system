
# Menu API Contract

This document defines the API contract for the Menu module of the Customer Ordering System.

The API supports:

- retrieving menu catalogs
    
- retrieving menu items
    
- searching menu items
    
- filtering menu catalogs
    

All endpoints require JWT authentication.

---

# Base URL

```http
/api/menu/
```

---

# Authentication

All menu endpoints require a valid JWT bearer token.

## Header

```http
Authorization: Bearer <JWT_TOKEN>
```

Unauthorized requests return:

```json
{
  "detail": "Authentication credentials were not provided."
}
```

Status Code:

```http
401 Unauthorized
```

---

# Data Model

## Menu Catalog Response Structure

```json
[
  {
    "id": "catalog_001",
    "label": "Main Dishes",
    "menuItems": [
      {
        "id": "item_001",
        "title": "Cheese Burger",
        "subtitle": "Grilled beef burger with cheese",
        "unitPrice": 8.99,
        "imageUrl": "https://example.com/images/burger.jpg",
        "category": "Burgers"
      }
    ]
  }
]
```

---

# 1. Get Menu Categories

Retrieve all active menu catalogs with their available menu items.

## Endpoint

```http
GET /api/menu/categories/
```

---

## Request Headers

```http
Authorization: Bearer <JWT_TOKEN>
```

---

## Query Parameters

|Parameter|Description|
|---|---|
|search|Search menu items by name or description|
|category|Filter catalogs by catalog name|

---

## Request Example

```http
GET /api/menu/categories/?search=burger&category=Main
Authorization: Bearer <JWT_TOKEN>
```

---

## Successful Response

### Status Code

```http
200 OK
```

### Response Body

```json
[
  {
    "id": "catalog_001",
    "label": "Main Dishes",
    "menuItems": [
      {
        "id": "item_001",
        "title": "Cheese Burger",
        "subtitle": "Grilled beef burger with cheese",
        "unitPrice": 8.99,
        "imageUrl": "https://example.com/images/burger.jpg",
        "category": "Burgers"
      }
    ]
  }
]
```

---

## Response Fields

### Menu Catalog Object

|Field|Description|
|---|---|
|id|Catalog unique identifier|
|label|Catalog name|
|menuItems|List of available menu items|

---

### Menu Item Object

|Field|Description|
|---|---|
|id|Menu item unique identifier|
|title|Menu item name|
|subtitle|Menu item description|
|unitPrice|Menu item price in dollars|
|imageUrl|Menu item image URL|
|category|Menu item category|

---

## Error Responses

### Unauthorized

```http
401 Unauthorized
```

```json
{
  "detail": "Authentication credentials were not provided."
}
```

---

### Internal Server Error

```http
500 Internal Server Error
```

```json
{
  "error": "Unable to load the menu at this time. Please try again later."
}
```

---

# Search Behavior

The `search` parameter performs case-insensitive matching against:

- menu item name
    
- menu item description
    

Example:

```http
GET /api/menu/categories/?search=pizza
```

---

# Filtering Behavior

The `category` parameter filters catalogs using partial case-insensitive matching against catalog names.

Example:

```http
GET /api/menu/categories/?category=Main
```

---

# Security Considerations

## Authentication

All endpoints require authenticated JWT tokens.

The API derives the authenticated user from the JWT token.

---

## Authorization

Only authenticated users can access the menu endpoints.

Unauthenticated requests are rejected with:

```http
401 Unauthorized
```

---

# Business Rules

|Rule|Description|
|---|---|
|Active catalogs only|Only catalogs marked as active are returned|
|Available items only|Only available menu items are returned|
|Alphabetical ordering|Catalogs are ordered alphabetically by name|
|Price conversion|Prices are stored in pennies and converted to dollars|
|Category normalization|Category FK is preferred over legacy category string|

---

# Error Handling

## Standard Error Format

```json
{
  "error": "Descriptive error message"
}
```

---

# HTTP Status Codes

|Status Code|Meaning|
|---|---|
|200 OK|Request successful|
|401 Unauthorized|Missing or invalid authentication|
|500 Internal Server Error|Unexpected server error|

---

# Traceability

This API contract supports the following use cases:

|Use Case|Description|
|---|---|
|UC1|Browse Menu|
|UC3|Manage Cart|
|UC4|Place Order|

The API behavior also aligns with the system business rules, including:

- active catalog filtering
    
- available item filtering
    
- search functionality
    
- catalog filtering
    
- authenticated access control
    
- normalized category handling