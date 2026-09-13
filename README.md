# Python
__pycache__/
*.py[cod]
.venv/
venv/

# Environment variables / secrets
.env
.env.*

# GCP credentials
*credentials*.json
*service-account*.json

# dbt
dbt/target/
dbt/logs/
dbt/dbt_packages/

# Terraform
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Local raw data
data/raw/