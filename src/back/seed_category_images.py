from django.db import transaction

from apps.menu.models import MenuItem as MenuItems

CATEGORY_IMAGE_MAP = {
    "Burger": "burger.jpg",
    "Chicken Sandwiches": "chicked_sandwich.jpg",
    "Fries Sandwiches": "fries_sandwitch.jpg",
    "Meals": "meals.jpg",
    "New Offers": "new_offers.jpg",
}


@transaction.atomic
def seed_images():
    updated_count = 0

    items = (
        MenuItems.objects
        .select_related("category_fk")
        .all()
    )

    for item in items:
        category_name = item.category_fk.name

        image_name = CATEGORY_IMAGE_MAP.get(category_name)

        if image_name is None:
            print(
                f"[WARNING] No image mapping for "
                f"category '{category_name}' "
                f"(item: {item.name})"
            )
            continue

        relative_path = image_name

        item.image_url = relative_path
        item.save(update_fields=["image_url"])

        updated_count += 1

        print(
            f"[UPDATED] {item.name} "
            f"-> {relative_path}"
        )

    print(f"\nDone. Updated {updated_count} menu items.")


seed_images()
