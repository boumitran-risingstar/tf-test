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

# --- Phase 1: Deploy Foundational Infrastructure ---
echo "--- Phase 1: Deploying Artifact Registry, Log Bucket, and IAM ---"
# Apply the foundational resources, including the log bucket and service account.
terraform apply -auto-approve \
  -target=google_artifact_registry_repository.default \
  -target=google_storage_bucket.cloudbuild_logs \
  -target=google_storage_bucket_iam_member.cloudbuild_log_writer \
  -target=google_storage_bucket.cloudbuild_source \
  -target=google_storage_bucket_iam_member.cloudbuild_source_admin \
  -target=google_service_account.cloudbuild \
  -target=google_project_iam_member.cloud_build_permissions \
  -target=google_service_account_iam_member.cloudbuild_is_serviceAccountUser_for_cloudrun \
  -var="project_id=${PROJECT_ID}" \
  -var="deploy_user_email=${DEPLOY_USER_EMAIL}" \
  -var="app_name=${APP_NAME}" \
  -var="service_name=${AUTH_UI_SERVICE_NAME}" \
  -var="region=${GCP_REGION}" \
  -var="use_load_balancer=${USE_LOAD_BALANCER}"

# --- Wait for IAM Propagation ---
echo "--- Waiting 10 seconds for IAM permissions to propagate... ---"
sleep 10

# --- Phase 2: Build & Push Application Image ---
echo "--- Phase 2: Building and Pushing Application Image to Artifact Registry ---"
cd ../auth-ui # Navigate to the application code

IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${APP_NAME}/${AUTH_UI_SERVICE_NAME}"
CLOUDBUILD_SA_NAME=$(cd ../terraform && terraform output -raw cloud_build_service_account_name)
LOG_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-logs"
SOURCE_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-source/source.tgz"


# Submit the build, sending logs to the dedicated GCS bucket.
gcloud builds submit --tag "${IMAGE_URL}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="${LOG_BUCKET_URI}" --gcs-source-staging-dir="${SOURCE_BUCKET_URI}" .

cd ../terraform # Return to the terraform directory

# --- Phase 3: Deploy Application Services ---
echo "--- Phase 3: Deploying Cloud Run and related services ---"
# Apply the rest of the configuration. Terraform will detect the existing
# resources and create the remaining ones.
terraform apply -auto-approve \
  -var="project_id=${PROJECT_ID}" \
  -var="deploy_user_email=${DEPLOY_USER_EMAIL}" \
  -var="app_name=${APP_NAME}" \
  -var="service_name=${AUTH_UI_SERVICE_NAME}" \
  -var="region=${GCP_REGION}" \
  -var="use_load_balancer=${USE_LOAD_BALANCER}"

# --- Phase 4: Post-Deployment Tests ---
echo "--- Phase 4: Running Post-Deployment Tests ---"
# Run the test script to verify the health and functionality of the deployment
./test/run-tests.sh

echo "--- Deployment and Testing Complete ---"
