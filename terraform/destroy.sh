#!/bin/bash
set -e

# --- Configuration ---
source "./config.sh"

# --- Destroying Infrastructure ---
echo "--- Destroying Infrastructure ---"
echo "Creating terraform.tfvars file..."
# Create a terraform.tfvars file
source ./create-tfvars.sh

echo "Initializing Terraform..."
terraform init

# Remove Cloud Run Domain Mapping from state if it exists and load balancer is NOT used, to retain it
if [ "$USE_LOAD_BALANCER" = "false" ]; then
  if terraform state list | grep -q 'google_cloud_run_domain_mapping.default\[0\]'; then
    echo "Removing google_cloud_run_domain_mapping.default[0] from Terraform state to retain it (Load Balancer not used)..."
    terraform state rm google_cloud_run_domain_mapping.default[0]
  else
    echo "google_cloud_run_domain_mapping.default[0] not found in state, skipping state removal (Load Balancer not used)."
  fi
else
  echo "Load Balancer is enabled, google_cloud_run_domain_mapping will be destroyed with other resources if it exists."
fi

echo "Destroying all remaining infrastructure..."
terraform destroy -auto-approve \
  -var="firestore_database_name=${FIRESTORE_DATABASE_NAME}" \
  -var="kms_project_id=${KMS_PROJECT_ID}"

echo "Cleaning up local Terraform files..."
rm -f terraform.tfvars
rm -rf .terraform/
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f .terraform.lock.hcl

echo "--- Infrastructure destroyed successfully! ---"
