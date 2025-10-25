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

# Create terraform.tfvars file
./create-tfvars.sh

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

# --- Import Existing Infrastructure ---
echo "--- Importing Existing Infrastructure if it exists---"

# Artifact Registry
if gcloud artifacts repositories describe mouth-metrics-docker-repo --location=${GCP_REGION} --project=${PROJECT_ID} &> /dev/null; then
  echo "Importing Artifact Registry..."
  terraform state show google_artifact_registry_repository.default &> /dev/null || terraform import google_artifact_registry_repository.default "projects/${PROJECT_ID}/locations/${GCP_REGION}/repositories/mouth-metrics-docker-repo"
fi

# Storage Buckets
if gcloud storage buckets describe gs://${PROJECT_ID}-cloudbuild-logs --project=${PROJECT_ID} &> /dev/null; then
  echo "Importing Cloud Build logs bucket..."
  terraform state show google_storage_bucket.cloudbuild_logs &> /dev/null || terraform import google_storage_bucket.cloudbuild_logs "${PROJECT_ID}-cloudbuild-logs"
fi
if gcloud storage buckets describe gs://${PROJECT_ID}-cloudbuild-source --project=${PROJECT_ID} &> /dev/null; then
  echo "Importing Cloud Build source bucket..."
  terraform state show google_storage_bucket.cloudbuild_source &> /dev/null || terraform import google_storage_bucket.cloudbuild_source "${PROJECT_ID}-cloudbuild-source"
fi

# Service Accounts
if gcloud iam service-accounts describe cloud-build-sa@${PROJECT_ID}.iam.gserviceaccount.com --project=${PROJECT_ID} &> /dev/null; then
  echo "Importing Cloud Build service account..."
  terraform state show google_service_account.cloudbuild &> /dev/null || terraform import google_service_account.cloudbuild "projects/${PROJECT_ID}/serviceAccounts/cloud-build-sa@${PROJECT_ID}.iam.gserviceaccount.com"
fi
if gcloud iam service-accounts describe auth-ui-sa@${PROJECT_ID}.iam.gserviceaccount.com --project=${PROJECT_ID} &> /dev/null; then
  echo "Importing Auth UI service account..."
  terraform state show google_service_account.default &> /dev/null || terraform import google_service_account.default "projects/${PROJECT_ID}/serviceAccounts/auth-ui-sa@${PROJECT_ID}.iam.gserviceaccount.com"
fi


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

REPOSITORY_ID=$(cd ../terraform && terraform output -raw repository_id)
IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${AUTH_UI_SERVICE_NAME}"
CLOUDBUILD_SA_NAME=$(cd ../terraform && terraform output -raw cloud_build_service_account_name)
LOG_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-logs"
SOURCE_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-source/source.tgz"


# Submit the build, sending logs to the dedicated GCS bucket.
gcloud builds submit --tag "${IMAGE_URL}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="${LOG_BUCKET_URI}" --gcs-source-staging-dir="${SOURCE_BUCKET_URI}" .

sleep 10

cd ../terraform # Return to the terraform directory

# --- Import Cloud Run Service ---
echo "--- Importing Cloud Run Service if it exists ---"
if gcloud run services describe ${AUTH_UI_SERVICE_NAME} --region ${GCP_REGION} --project ${PROJECT_ID} &> /dev/null; then
  echo "Importing Cloud Run service..."
  terraform state show google_cloud_run_v2_service.default &> /dev/null || terraform import google_cloud_run_v2_service.default "projects/${PROJECT_ID}/locations/${GCP_REGION}/services/${AUTH_UI_SERVICE_NAME}"
fi


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
