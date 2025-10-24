#!/bin/bash
set -e

# This script automates the deployment of the Mouth Metrics application.

# --- Configuration ---

# Navigate to the Terraform directory.
cd terraform

# Extract variables from Terraform configuration files.
PROJECT_ID=$(grep 'project_id' terraform.tfvars | awk -F'"' '{print $2}')
GCP_REGION=$(awk '/variable "gcp_region"/, /}/' variables.tf | grep 'default' | awk -F'"' '{print $2}')
APP_NAME=$(grep 'app_name' terraform.tfvars | awk -F'"' '{print $2}')
DEPLOY_USER_EMAIL=$(gcloud config get-value account)

# Replicate the logic from locals.tf to construct resource names.
REPOSITORY_ID="${APP_NAME}-repo"
IMAGE_NAME="${APP_NAME}-image"
CERT_NAME="${APP_NAME}-ssl-cert"

# Get the short hash of the latest git commit to use as the image tag.
IMAGE_TAG=$(git rev-parse --short HEAD)

# Construct the full image URL.
IMAGE_URL="$GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_ID/$IMAGE_NAME"

# --- Deployment Steps ---

# 1. Initialize Terraform
echo "Initializing Terraform..."
terraform init

# 2. Import the SSL certificate if it's not already in the state
# This prevents errors if the certificate was created outside of a 'terraform apply' run.
echo "Checking for existing SSL certificate..."
# The '|| true' ensures that the script doesn't fail if the grep command finds no matches.
if ! terraform state list | grep -q "google_compute_managed_ssl_certificate.ssl_certificate\\[0\\]"; then
  echo "Certificate not found in state, attempting to import..."
  # The '|| true' will prevent the script from exiting if the import fails (e.g., the cert doesn't exist yet).
  # Terraform apply will then create it.
  terraform import "google_compute_managed_ssl_certificate.ssl_certificate[0]" "$CERT_NAME" || true
else
  echo "Certificate already in state. Skipping import."
fi

# 3. Run validation tests
echo "Running validation tests..."
tflint --init
tflint
terraform validate

# 4. Apply foundational infrastructure
echo "Applying foundational infrastructure (Artifact Registry)..."
terraform apply -auto-approve -target="google_artifact_registry_repository.repository"

# 5. Check if the image already exists
if gcloud artifacts docker images describe "${IMAGE_URL}:${IMAGE_TAG}" --quiet &> /dev/null; then
  echo "Image with tag ${IMAGE_TAG} already exists. Skipping build."
else
  # 6. Build and Push the Docker Image
  echo "Building and pushing the Docker image to ${IMAGE_URL}:${IMAGE_TAG}..."
  gcloud builds submit --tag "${IMAGE_URL}:${IMAGE_TAG}" ../src
fi

# 7. Apply Terraform
# This creates the necessary infrastructure and deploys the application.
echo "Applying Terraform to deploy the new image..."
terraform apply -auto-approve -var="deploy_user_email=$DEPLOY_USER_EMAIL" -var="image_tag=$IMAGE_TAG"

# 8. Run post-deployment tests
echo "Running post-deployment tests..."
# The script needs the URL of the load balancer to run the tests.
LB_URL="https://$(terraform output -raw lb_ip_address)"
./test/run-tests.sh "$LB_URL"
