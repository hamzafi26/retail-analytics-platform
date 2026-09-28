# Data Layers and Naming Conventions

## Data Layers

The platform uses three main data layers:

```text
RAW
 ↓
STAGING
 ↓
MARTS
```

### RAW

Source data loaded with minimal changes.

Examples:

```text
raw_customers
raw_orders
raw_order_items
raw_products
raw_sellers
raw_payments
raw_reviews
raw_geolocation
```

### STAGING

Cleaned and standardized data.

Examples:

```text
stg_customers
stg_orders
stg_order_items
stg_products
stg_sellers
stg_payments
stg_reviews
```

### MARTS

Business-ready analytical tables.

Dimensions:

```text
dim_customer
dim_product
dim_seller
dim_date
```

Facts:

```text
fact_orders
fact_order_items
fact_payments
```

## BigQuery Dataset Naming

```text
retail_raw
retail_staging
retail_marts
```

## Table Naming

Raw tables:

```text
raw_<entity>
```

Staging tables:

```text
stg_<entity>
```

Dimension tables:

```text
dim_<entity>
```

Fact tables:

```text
fact_<entity>
```

## Cloud Storage Structure

```text
gs://retail-analytics-platform-data/

raw/
    customers/
    orders/
    order_items/
    products/
    sellers/
    payments/
    reviews/
    geolocation/
    product_categories/
```

## Naming Rules

- use lowercase
- use snake_case
- avoid spaces
- use clear business names
- keep naming consistent across GCS, BigQuery, and dbt
