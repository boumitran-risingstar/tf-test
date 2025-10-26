#!/bin/bash
# --- Resilient Deployment Script ---
# This script automates the deployment of the application's infrastructure.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# Source the configuration file to get environment variables
if [ -f "config.sh" ]; then
  source config.sh
else
  echo "Error: Configuration file 'config.sh' not found."
  exit 1
fi

# --- Argument Parsing ---
# If no arguments are provided, deploy all services
if [ "$#" -eq 0 ]; then
  set -- "auth-ui" "users-api"
fi

echo "--- Deploying the following services: $@ ---"


# Create terraform.tfvars file
./create-tfvars.sh

# --- Pre-flight Checks ---
echo "--- Running Pre-flight Checks ---"
cd terraform

# Import Identity Platform config if it doesn't exist in the state
if ! terraform state list | grep -q google_identity_platform_config.default; then
  echo "Importing Identity Platform config..."
  terraform import google_identity_platform_config.default projects/$PROJECT_ID
fi

# Import default supported IdP config for google.com if it doesn't exist in the state
if ! terraform state list | grep -q google_identity_platform_default_supported_idp_config.google; then
  echo "Importing default supported IdP config for google.com..."
  terraform import google_identity_platform_default_supported_idp_config.google projects/$PROJECT_ID/defaultSupportedIdpConfigs/google.com
fi

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

# --- Pre-deploy step: Disable deletion protection on Cloud Run ---
echo "--- Disabling deletion protection on Cloud Run service ---"
terraform apply -auto-approve -var="deploy_cloud_run=true" -target="google_cloud_run_v2_service.default[0]"

# --- Deploy Infrastructure (without Cloud Run) ---
echo "--- Deploying Infrastructure (without Cloud Run) ---"
terraform apply -auto-approve -var="deploy_cloud_run=false"

# --- Build & Push Images ---
for service in "$@"
do
  if [ "$service" = "auth-ui" ]; then
    echo "--- Building and Pushing Application Image to Artifact Registry ---"
    cd ../auth-ui # Navigate to the application code

    REPOSITORY_ID=$(cd ../terraform && terraform output -raw repository_id)
    IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${AUTH_UI_SERVICE_NAME}"
    CLOUDBUILD_SA_NAME=$(cd ../terraform && terraform output -raw cloud_build_service_account_name)
    LOG_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-logs"
    SOURCE_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-source/source.tgz"

    # Submit the build
    gcloud builds submit --tag "${IMAGE_URL}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="${LOG_BUCKET_URI}" --gcs-source-staging-dir="${SOURCE_BUCKET_URI}" .

    sleep 10

  elif [ "$service" = "users-api" ]; then
    echo "--- Building and Pushing Users API Image to Artifact Registry ---"
    cd ../users-api # Navigate to the application code

    REPOSITORY_ID=$(cd ../terraform && terraform output -raw repository_id)
    IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${USERS_API_SERVICE_NAME}"
    CLOUDBUILD_SA_NAME=$(cd ../terraform && terraform output -raw cloud_build_service_account_name)
    LOG_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-logs"
    SOURCE_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-source/source.tgz"

    # Submit the build
    gcloud builds submit --tag "${IMAGE_URL}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="${LOG_BUCKET_URI}" --gcs-source-staging-dir="${SOURCE_BUCKET_URI}" .

    sleep 10
  else
    echo "Invalid service: $service. Available services: auth-ui, users-api"
    exit 1
  fi
done


cd ../terraform # Return to the terraform directory

# --- Deploy Cloud Run Service ---
echo "--- Deploying Cloud Run Service ---"
# Terraform will automatically detect which image has been updated and only
# deploy the service with the new image.
terraform apply -auto-approve -var="deploy_cloud_run=true" -var "firestore_database_name=${FIRESTORE_DATABASE_NAME}"

# --- Post-Deployment Tests ---
echo "--- Running Post-Deployment Tests ---"
# Run the test script to verify the health and functionality of the deployment
./test/run-tests.sh

echo "--- Deployment and Testing Complete ---"