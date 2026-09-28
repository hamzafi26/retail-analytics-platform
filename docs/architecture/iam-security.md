# IAM and Security Model

## Service Accounts

### ingestion-sa

Used by ingestion workloads.

Access:

- Read/write Cloud Storage
- Load data into BigQuery
- Write logs

### dataflow-sa

Used by Dataflow jobs.

Access:

- Read from Pub/Sub
- Read/write BigQuery
- Read/write Cloud Storage
- Write logs

### workflow-sa

Used by Google Workflows.

Access:

- Trigger Cloud Run jobs
- Trigger other workflow steps
- Write logs

### dbt-sa

Used for dbt transformations.

Access:

- Read RAW datasets
- Read/write STAGING datasets
- Read/write MARTS datasets

## Security Rules

- Use separate service accounts for different workloads
- Apply least-privilege permissions
- Do not store credentials in GitHub
- Store secrets in Secret Manager
- Avoid long-lived service account keys
- Restrict access to project resources