# Retail Analytics Platform - Architecture

## Batch Architecture

```mermaid
flowchart LR
    A[Olist CSV Dataset] --> B[Cloud Storage]
    B --> C[BigQuery RAW]
    C --> D[dbt]
    D --> E[BigQuery STAGING]
    E --> F[BigQuery MARTS]
    F --> G[Looker Studio]
```

## Streaming Architecture

```mermaid
flowchart LR
    A[Python Event Simulator] --> B[Pub/Sub]
    B --> C[Dataflow]
    C --> D[BigQuery]
    D --> E[Looker Studio]
```

## Data Layers

```text
RAW
 ↓
STAGING
 ↓
MARTS
```

## Main Services

- Cloud Storage
- BigQuery
- dbt
- Looker Studio
- Pub/Sub
- Dataflow
- Cloud Run
- Cloud Scheduler
- Workflows
- IAM
- Secret Manager
- Cloud Logging
- Cloud Monitoring

## DevOps

- Terraform
- Docker
- GitHub Actions
- GitHub

## Optional Extensions

- PySpark
- AI
