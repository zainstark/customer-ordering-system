import uuid
from django.utils import timezone
from django.contrib.auth.hashers import make_password

from apps.authentication.models import Accounts
from apps.menu.models import MenuCatalog, Category, MenuItem

now = timezone.now()


def new_id():
    return str(uuid.uuid4())


# ---------- CATALOG ----------
catalog, _ = MenuCatalog.objects.get_or_create(
    name="Main Menu",
    defaults={
        "catalog_id": new_id(),
        "active": True,
        "created_at": now,
        "updated_at": now,
    },
)


# ---------- CATEGORIES ----------
category_names = [
    "Burger",
    "Chicken Sandwiches",
    "Fries Sandwiches",
    "Meals",
    "New Offers",
]

categories = {}

for category_name in category_names:
    category, _ = Category.objects.get_or_create(
        name=category_name,
        defaults={
            "category_id": new_id(),
            "created_at": now,
            "updated_at": now,
        },
    )
    categories[category_name] = category


# ---------- MENU ITEMS ----------
menu_items = {
    "Burger": [
        {
            "name": "Cheeseburger",
            "description": "Steak patty with lettuce, tomato, pickles, onion, mayonnaise, and cheddar cheese.",
            "price": 11100,
        },
        {
            "name": "Volcano Burger",
            "description": "Beef patty with lettuce, tomato, pickles, onion, mayonnaise, and cheddar cheese.",
            "price": 13800,
        },
        {
            "name": "Hammer Burger",
            "description": "Smash burger patty with mozzarella sticks, onion rings, cheddar cheese, texas sauce, and pickles.",
            "price": 13800,
        },
        {
            "name": "Hickory Burger",
            "description": "Beef patty with lettuce and hickory smoked flavor.",
            "price": 12600,
        },
        {
            "name": "Double Cheeseburger",
            "description": "Two beef patties with lettuce and tomatoes.",
            "price": 0,  # fill later
        },
    ],

    "Chicken Sandwiches": [
        {
            "name": "Shish Hot Dog Mozzarella Sandwich",
            "description": "Mozzarella hot dog shish sandwich with melted mozzarella cheese and grilled hot dog shish.",
            "price": 14200,
        },
        {
            "name": "Smoked Chicken Sandwich",
            "description": "Smoked chicken breast with special sauce.",
            "price": 12900,
        },
        {
            "name": "sandawsh ranch kranch",
            "description": "Crispy chicken ranch sandwich with ranch dressing and lettuce.",
            "price": 12900,
        },
        {
            "name": "Classic Chicken or Cheese Sandwich",
            "description": "Crispy chicken fillet sandwich with cheese options.",
            "price": 14714,
        },
        {
            "name": "Turkey Cordon Bleu Sandwich",
            "description": "Chicken stuffed with cheese, smoked turkey, lettuce, and mayonnaise.",
            "price": 12900,
        },
        {
            "name": "Big Shish Sandwich",
            "description": "Grilled chicken thighs with peppers, onions, and mayo.",
            "price": 12900,
        },
        {
            "name": "Cheese Crunch Sandwich",
            "description": "Crispy chicken strips with cheddar cheese sauce, lettuce, and sweet chili sauce.",
            "price": 12900,
        },
    ],

    "Fries Sandwiches": [
        {
            "name": "Classic Potatoes Sandwich",
            "description": "Crispy French fries served without toppings.",
            "price": 4200,
        },
        {
            "name": "Mix Cheese Potatoes Sandwich",
            "description": "French fries with mixed cheeses.",
            "price": 5900,
        },
        {
            "name": "Mozzarella Potatoes Sandwich",
            "description": "French fries topped with mozzarella cheese.",
            "price": 5900,
        },
        {
            "name": "Cheddar Potatoes Sandwich",
            "description": "French fries topped with cheddar cheese.",
            "price": 5200,
        },
    ],

    "Meals": [
        {
            "name": "3 Piece Crunchy Meal",
            "description": "Rice, three crunchy crispy pieces, fries, and coleslaw.",
            "price": 17599,
        },
        {
            "name": "Cordon Bleu Meal",
            "description": "Chicken breasts stuffed with cheese and butter served with potatoes.",
            "price": 18100,
        },
        {
            "name": "Crunchy Meal Potatoes 4 Pieces",
            "description": "وجبة تشمل طبق أرز مع ثلاث قطع كريسبي، بطاطس ذهبية، سلطة كول سلو، وصلصة.",
            "price": 20700,
        },
        {
            "name": "Shish Tawook Meal",
            "description": "Charcoal grilled shish tawook with rice and fries.",
            "price": 20700,
        },
    ],
}

for category_name, items in menu_items.items():
    category = categories[category_name]

    for item in items:
        MenuItem.objects.get_or_create(
            name=item["name"],
            defaults={
                "menu_item_id": new_id(),
                "catalog": catalog,
                "category_fk": category,
                "description": item["description"],
                "price_penny": item["price"],
                "available": True,
                "image_url": None,
                "created_at": now,
                "updated_at": now,
            },
        )


# ---------- ACCOUNTS ----------
accounts = [
    {
        "display_name": "Admin",
        "email": "admin@zesty.com",
        "role": "admin",
    },
    {
        "display_name": "Chef",
        "email": "chef@zesty.com",
        # schema constraint doesn't allow chef role
        "role": "admin",
    },
]

for acc in accounts:
    Accounts.objects.get_or_create(
        email=acc["email"],
        defaults={
            "account_id": new_id(),
            "display_name": acc["display_name"],
            "role": acc["role"],
            "password_hash": make_password("12345678"),
            "phone_number": None,
            "active": True,
            "created_at": now,
            "updated_at": now,
        },
    )

print("Done seeding DB")
