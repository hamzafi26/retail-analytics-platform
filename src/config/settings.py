from pathlib import Path
import pandas
DATA_PATH = Path(__file__).parent.parent.parent / "data"
SCHEMA_PATH = Path(__file__).parent / "schemas"
SCHEMA_FILES = {
    "customer": "customers_schema.yaml",
    "geolocation": "geolocation_schema.yaml",
    "order_items": "order_items_schema.yaml",
    "order_payments": "order_payments_schema.yaml",
    "order_reviews": "order_reviews_schema.yaml",
    "orders": "orders_schema.yaml",
    "products": "product_schema.yaml",
    "sellers": "sellers_schema.yaml",
    "category_name_translation": "category_name_translation_schema.yaml",
}


CONVERTERS = {
    "integer": lambda series: series.astype("Int64"),
    "string": lambda series: series.astype("string"),
    "datetime": pandas.to_datetime,
    "float": lambda series: series.astype("float64"),
}
