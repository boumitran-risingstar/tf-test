#!/bin/bash
# This script creates a terraform.tfvars file from environment variables.

# Source the configuration file to get environment variables
if [ -f "config.sh" ]; then
  source config.sh
else
  echo "Error: Configuration file 'config.sh' not found."
  exit 1
fi

# Create the terraform.tfvars file
cat <<EOF > terraform/terraform.tfvars
project_id          = "${PROJECT_ID}"
deploy_user_email   = "${DEPLOY_USER_EMAIL}"
app_name            = "${APP_NAME}"
service_name        = "${AUTH_UI_SERVICE_NAME}"
region              = "${GCP_REGION}"
use_load_balancer   = ${USE_LOAD_BALANCER}
domain_name         = "${DOMAIN_NAME}"
EOF

echo "terraform.tfvars file created successfully."
