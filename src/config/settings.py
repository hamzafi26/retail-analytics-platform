from pathlib import Path

DATA_PATH = Path(__file__).parent.parent.parent / "data"

EXPECTED_DATA_FILES = {
    "customer": "olist_customers_dataset.csv",
    "geolocation": [
        "olist_geolocation_dataset_part1.csv",
        "olist_geolocation_dataset_part2.csv",
    ],
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "category_name_translation": "product_category_name_translation.csv",
}
