# Retail Analytics Platform

## Overview

**Retail Analytics Platform** is an end-to-end Data Engineering project built on **Google Cloud Platform (GCP)**.

The goal of this project is to practice and demonstrate real-world cloud data engineering skills by building a complete retail analytics platform that ingests, stores, transforms, models, monitors, and visualizes e-commerce data.

The project is also designed to be part of my professional portfolio and to demonstrate practical experience with GCP, Data Engineering, SQL, Python, dbt, streaming, infrastructure automation, and analytics.

---

## Business Use Case

The platform simulates a retail/e-commerce company that wants to centralize its operational data and provide analytics for areas such as:

- Sales performance
- Orders
- Customers
- Products
- Sellers
- Payments
- Delivery performance
- Customer satisfaction

The final platform will allow business users to monitor important KPIs such as:

- Total revenue
- Total orders
- Average order value
- Revenue by month
- Revenue by product category
- Top products
- Top sellers
- Orders by status
- Average delivery time
- Late delivery rate
- Average customer review score
- Payment method distribution
- Customer repeat rate

---

## Dataset

The project uses the **Olist Brazilian E-Commerce Dataset**.

The dataset contains real anonymized e-commerce data related to:

- Customers
- Orders
- Order items
- Products
- Sellers
- Payments
- Reviews
- Geolocation
- Product categories

The main data relationships are:

```text
Customers
    │
    ▼
Orders
 ├────────► Order Items ─────► Products
 │                 │
 │                 └────────► Sellers
 │
 ├────────► Payments
 │
 └────────► Reviews
```

---

## Target Architecture

The core architecture of the project will be:

```text
                   BATCH PIPELINE

Source CSV Files
      │
      ▼
Cloud Storage
      │
      ▼
BigQuery Raw Layer
      │
      ▼
     dbt
      │
      ▼
BigQuery Analytics Layer
      │
      ▼
Looker Studio
```

A real-time pipeline will also be added:

```text
Python Event Simulator
        │
        ▼
      Pub/Sub
        │
        ▼
     Dataflow
        │
        ▼
     BigQuery
```

---

## Main Technologies

### Google Cloud Platform

- Cloud Storage
- BigQuery
- Pub/Sub
- Dataflow
- Cloud Run
- Cloud Scheduler
- Workflows
- IAM
- Secret Manager
- Cloud Logging
- Cloud Monitoring
- Artifact Registry

### Data Engineering

- Python
- SQL
- dbt
- Apache Beam

### Infrastructure and DevOps

- Terraform
- Docker
- Git
- GitHub
- GitHub Actions

### Analytics

- Looker Studio

### Python Environment

- uv

---

## Project Roadmap

### Phase 0 - Project Foundation

- Create the GCP project
- Configure billing alerts
- Create the local project structure
- Initialize Git
- Configure `.gitignore`
- Install and configure Google Cloud CLI
- Enable the required GCP APIs
- Configure the Python environment with uv

### Phase 1 - Data Understanding

- Download the source dataset
- Explore the CSV files
- Analyze columns and data types
- Check missing values
- Check duplicates
- Identify primary and foreign keys
- Understand relationships between datasets
- Define business KPIs
- Design the target data model

### Phase 2 - Data Lake

- Create Cloud Storage buckets
- Design the raw data structure
- Upload source files
- Organize data by domain
- Configure permissions

### Phase 3 - Batch Ingestion

- Build Python ingestion scripts
- Validate input files
- Load raw data into GCP
- Containerize ingestion code
- Run ingestion workloads with Cloud Run

### Phase 4 - BigQuery Data Warehouse

- Create BigQuery datasets
- Create raw tables
- Define schemas
- Load data from Cloud Storage
- Apply partitioning
- Apply clustering
- Optimize analytical queries

### Phase 5 - dbt Transformation Layer

- Configure dbt with BigQuery
- Define sources
- Create staging models
- Create intermediate models
- Build fact tables
- Build dimension tables
- Implement data quality tests
- Add documentation
- Implement incremental models

The analytical model will include tables such as:

```text
dim_customer
dim_product
dim_seller
dim_date

fact_orders
fact_order_items
fact_payments
```

### Phase 6 - Analytics Dashboard

Build a Looker Studio dashboard containing:

- Revenue KPIs
- Order KPIs
- Product performance
- Seller performance
- Customer analytics
- Delivery performance
- Payment analysis
- Customer satisfaction

The dashboard will be accessible from the portfolio.

### Phase 7 - Real-Time Data Pipeline

A Python application will simulate new retail order events.

The streaming architecture will be:

```text
Python
   │
   ▼
Pub/Sub
   │
   ▼
Dataflow
   │
   ▼
BigQuery
```

This phase will introduce:

- Event-driven architecture
- Message queues
- Streaming ingestion
- Apache Beam
- Real-time processing

### Phase 8 - Orchestration

Use:

- Cloud Scheduler
- Google Workflows
- Cloud Run

to orchestrate the different pipeline components.

### Phase 9 - Security and Monitoring

Implement:

- IAM roles
- Service accounts
- Least-privilege access
- Secret Manager
- Cloud Logging
- Cloud Monitoring
- Pipeline alerts

### Phase 10 - Infrastructure as Code

Use **Terraform** to provision GCP resources such as:

- Cloud Storage
- BigQuery
- Pub/Sub
- IAM
- Cloud Run
- Artifact Registry
- Scheduler

### Phase 11 - CI/CD

Use GitHub Actions to automate:

- Python tests
- dbt tests
- Terraform validation
- Docker builds
- Deployment

### Phase 12 - Portfolio Documentation

Complete the project documentation with:

- Architecture diagrams
- Technical decisions
- Screenshots
- Data model
- Dashboard
- Setup instructions
- Lessons learned

---

## Optional Extensions

After the core platform is complete, additional components may be added if time permits.

### PySpark

PySpark may be introduced as an additional batch-processing layer for practicing distributed data processing.

Example:

```text
Cloud Storage
      │
      ▼
   PySpark
      │
      ▼
   BigQuery
```

PySpark is not required by the core architecture and will only be added as an additional learning exercise.

### Artificial Intelligence

An AI component may also be added at the end of the project.

Possible examples include:

- Sales insights generation
- Automated business summaries
- Product analytics assistant
- Natural-language querying of analytical data
- Anomaly explanation

The AI component will only be added after the core Data Engineering platform is complete.

---

## Project Goal

By completing this project, I aim to demonstrate practical knowledge of:

- Cloud Data Engineering
- GCP architecture
- Batch processing
- Streaming processing
- Data warehousing
- Data modeling
- ELT pipelines
- Data quality
- Infrastructure as Code
- CI/CD
- Monitoring
- Security
- Business Intelligence

The final result will be a deployable and documented cloud data platform that can be presented as part of my Data Engineering portfolio.