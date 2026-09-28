# Business Requirements

## 1. Project Objective

The Retail Analytics Platform aims to centralize and analyze retail/e-commerce data in order to provide reliable insights about sales, customers, products, sellers, payments, deliveries, and customer satisfaction.

The platform will transform raw operational data into analytics-ready datasets that can be consumed through dashboards and reporting tools.

---

## 2. Business Questions

The platform should answer questions such as:

### Sales
- What is the total revenue?
- How does revenue evolve over time?
- What is the total number of orders?
- What is the average order value?
- Which product categories generate the most revenue?

### Customers
- How many unique customers are there?
- Where are customers located?
- How many customers make repeat purchases?

### Products
- Which products and categories sell the most?
- Which categories generate the highest revenue?

### Sellers
- Which sellers generate the most revenue?
- Which sellers process the most orders?

### Delivery
- What is the average delivery time?
- How many orders are delivered late?
- Which sellers have the highest delivery delays?

### Payments
- Which payment methods are most commonly used?
- What is the distribution of payment installments?

### Customer Satisfaction
- What is the average review score?
- How does review score relate to delivery performance?

---

## 3. Key KPIs

The first version of the platform will provide:

- Total Revenue
- Total Orders
- Unique Customers
- Average Order Value
- Revenue by Month
- Revenue by Product Category
- Top Products
- Top Sellers
- Average Delivery Time
- Late Delivery Rate
- Average Review Score
- Payment Method Distribution
- Customer Repeat Rate

---

## 4. Required Olist Datasets

The following datasets are required:

- `olist_customers_dataset.csv`
- `olist_orders_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_products_dataset.csv`
- `olist_sellers_dataset.csv`
- `olist_order_payments_dataset.csv`
- `olist_order_reviews_dataset.csv`
- `olist_geolocation_dataset.csv`
- `product_category_name_translation.csv`

---

## 5. First-Version Scope

The first version will include:

- Historical batch ingestion
- Raw data storage in Google Cloud Storage
- Raw and analytical data storage in BigQuery
- Data transformation and modeling with dbt
- Data quality checks
- Business-ready fact and dimension tables
- Analytics dashboards in Looker Studio

The real-time pipeline using Pub/Sub and Dataflow will be implemented in a later phase.

PySpark and AI are optional extensions and are not part of the core first version.