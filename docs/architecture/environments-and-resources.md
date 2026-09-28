# Environments and Resource Naming

## Environments

The project will use:

```text
dev
prod
```

For the portfolio project, development will be used first.

Production will only be added if needed later.

## Naming Pattern

Resources will follow this pattern:

```text
<project>-<environment>-<resource>
```

Examples:

```text
retail-analytics-dev-data
retail-analytics-dev-ingestion
retail-analytics-dev-events
```

## GCP Resources

### Cloud Storage

```text
retail-analytics-dev-data
```

### BigQuery

```text
retail_raw
retail_staging
retail_marts
```

### Pub/Sub

```text
retail-analytics-dev-orders
```

### Cloud Run

```text
retail-analytics-dev-ingestion
```

### Artifact Registry

```text
retail-analytics-dev-images
```

### Workflows

```text
retail-analytics-dev-pipeline
```

## Naming Rules

- lowercase only
- use hyphens for GCP resources
- use underscores for BigQuery datasets and tables
- include environment when useful
- keep names short and descriptive
- avoid random abbreviations
