#!/bin/bash
# --- Resilient Deployment Script ---
# This script automates the deployment of the application's infrastructure
# in multiple phases to ensure stability and handle dependencies correctly.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# Source the configuration file to get environment variables
if [ -f "config.sh" ]; then
  source config.sh
else
  echo "Error: Configuration file 'config.sh' not found."
  exit 1
fi

# --- Pre-flight Checks ---
echo "--- Running Pre-flight Checks ---"
cd terraform

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Initialize TFLint
echo "Initializing TFLint..."
tflint --init

# Lint the Terraform configuration for best practices
echo "Linting Terraform configuration with TFLint..."
tflint

# Validate the Terraform configuration for syntax errors
echo "Validating Terraform configuration..."
terraform validate

# --- Phase 1: Deploy Artifact Registry ---
echo "--- Phase 1: Deploying Artifact Registry ---"
# Apply only the Artifact Registry to ensure it exists before we push an image.
# The resource name is derived from your terraform files (google_artifact_registry_repository.default)
terraform apply -auto-approve -target=google_artifact_registry_repository.default \
  -var="project_id=${PROJECT_ID}" \
  -var="deploy_user_email=${DEPLOY_USER_EMAIL}" \
  -var="app_name=${APP_NAME}" \
  -var="service_name=${AUTH_UI_SERVICE_NAME}" \
  -var="region=${GCP_REGION}"

# --- Wait for IAM Propagation ---
echo "--- Waiting 30 seconds for IAM permissions to propagate... ---"
sleep 30

# --- Phase 2: Build & Push Application Image ---
echo "--- Phase 2: Building and Pushing Application Image to Artifact Registry ---"
cd ../auth-ui # Navigate to the application code

IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${APP_NAME}/${AUTH_UI_SERVICE_NAME}"

# Use Google Cloud Build to build the image and push it to the registry
gcloud builds submit --tag "${IMAGE_URL}" .

cd ../terraform # Return to the terraform directory

# --- Phase 3: Deploy Application Services ---
echo "--- Phase 3: Deploying Cloud Run and related services ---"
# Apply the rest of the configuration. Terraform will detect the existing
# Artifact Registry and create the remaining resources.
terraform apply -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="deploy_user_email=${DEPLOY_USER_EMAIL}" \
  -var="app_name=${APP_NAME}" \
  -var="service_name=${AUTH_UI_SERVICE_NAME}" \
  -var="region=${GCP_REGION}"

# --- Phase 4: Post-Deployment Tests ---
echo "--- Phase 4: Running Post-Deployment Tests ---"
# Run the test script to verify the health and functionality of the deployment
./test/run-tests.sh

echo "--- Deployment and Testing Complete ---"
