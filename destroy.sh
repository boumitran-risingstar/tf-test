#!/bin/bash
set -e

# --- Configuration ---
source "./config.sh"

# --- Destroying Infrastructure ---
echo "--- Destroying Infrastructure ---"
echo "Creating terraform.tfvars file..."
# Create a terraform.tfvars file
cat > terraform/terraform.tfvars << EOL
project_id = "$PROJECT_ID"
gcp_region = "$GCP_REGION"
domain_name = "$DOMAIN_NAME"
app_name = "$APP_NAME"
deploy_user_email = "$DEPLOY_USER_EMAIL"
use_load_balancer = $USE_LOAD_BALANCER
EOL

cd terraform

echo "Initializing Terraform..."
terraform init

echo "Destroying all infrastructure..."
terraform destroy -auto-approve

cd ..

echo "--- Infrastructure destroyed successfully! ---"