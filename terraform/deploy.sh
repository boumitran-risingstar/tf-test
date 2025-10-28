#!/bin/bash
# --- Resilient Deployment Script ---
# This script automates the deployment of the application's infrastructure.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# Source the configuration file to get environment variables
if [ -f "./config.sh" ]; then
  source ./config.sh
else
  echo "Error: Configuration file './config.sh' not found."
  exit 1
fi

# --- Argument Parsing ---
# If no arguments are provided, deploy all services
if [ "$#" -eq 0 ]; then
  set -- "auth-ui" "users-api"
fi

echo "--- Deploying the following services: $@ ---"


# Create terraform.tfvars file
source ./create-tfvars.sh

# --- Pre-flight Checks & Initial Infrastructure Deployment ---
echo "--- Running Pre-flight Checks & Initial Infrastructure Deployment ---"

# Initialize Terraform (MUST run before any terraform state commands)
echo "Initializing Terraform..."
terraform init

# --- Conditional Imports ---
# These imports bring existing resources under Terraform's management if they exist.
# If an import fails (e.g., resource does not exist), the script will continue,
# allowing 'terraform apply' to create the resource if defined in .tf files.

# Import Identity Platform config if it doesn't exist in the state
if ! terraform state list | grep -q google_identity_platform_config.default; then
  echo "Importing Identity Platform config..."
  terraform import google_identity_platform_config.default projects/$PROJECT_ID || true
fi

# Import default supported IdP config for google.com if it doesn't exist in the state
if ! terraform state list | grep -q google_identity_platform_default_supported_idp_config.google; then
  echo "Importing default supported IdP config for google.com..."
  terraform import google_identity_platform_default_supported_idp_config.google projects/$PROJECT_ID/defaultSupportedIdpConfigs/google.com || true
fi

# Import Service Accounts if they exist
if ! terraform state list | grep -q google_service_account.default; then
  echo "Importing auth-ui-sa service account..."
  terraform import google_service_account.default projects/$PROJECT_ID/serviceAccounts/auth-ui-sa@$PROJECT_ID.iam.gserviceaccount.com || true
fi
if ! terraform state list | grep -q google_service_account.users_api; then
  echo "Importing users-api-sa service account..."
  terraform import google_service_account.users_api projects/$PROJECT_ID/serviceAccounts/users-api-sa@$PROJECT_ID.iam.gserviceaccount.com || true
fi
if ! terraform state list | grep -q google_service_account.cloudbuild; then
  echo "Importing cloud-build-sa service account..."
  terraform import google_service_account.cloudbuild projects/$PROJECT_ID/serviceAccounts/cloud-build-sa@$PROJECT_ID.iam.gserviceaccount.com || true
fi

# Import Secret Manager Secret if it exists
if ! terraform state list | grep -q google_secret_manager_secret.firebase_service_account_key; then
  echo "Importing firebase-service-account-key secret..."
  terraform import google_secret_manager_secret.firebase_service_account_key projects/$PROJECT_ID/secrets/firebase-service-account-key || true
fi

# Import Artifact Registry Repository if it exists
if ! terraform state list | grep -q google_artifact_registry_repository.default; then
  echo "Importing Artifact Registry repository..."
  terraform import google_artifact_registry_repository.default projects/$PROJECT_ID/locations/$GCP_REGION/repositories/${APP_NAME}-docker-repo || true
fi

# Import Firestore database if it doesn't exist in the state. Continue if import fails.
if ! terraform state list | grep -q 'google_firestore_database.database\.'; then
  echo "Importing Firestore database..."
  terraform import 'google_firestore_database.database[0]' projects/$PROJECT_ID/databases/$FIRESTORE_DATABASE_NAME || true
fi

# Import KMS KeyRing if it exists
if ! terraform state list | grep -q 'google_kms_key_ring.firestore_key_ring\.'; then
  echo "Importing KMS KeyRing..."
  terraform import 'google_kms_key_ring.firestore_key_ring[0]' projects/$KMS_PROJECT_ID/locations/$GCP_REGION/keyRings/${APP_NAME}-firestore-keyring || true
fi

# Import KMS CryptoKey if it exists
if ! terraform state list | grep -q 'google_kms_crypto_key.firestore_cmek_key\.'; then
  echo "Importing KMS CryptoKey..."
  terraform import 'google_kms_crypto_key.firestore_cmek_key[0]' projects/$KMS_PROJECT_ID/locations/$GCP_REGION/keyRings/${APP_NAME}-firestore-keyring/cryptoKeys/${APP_NAME}-firestore-cmek-key || true
fi

# Initialize TFLint
echo "Initializing TFLint..."
tflint --init

# Lint the Terraform configuration for best practices
echo "Linting Terraform configuration with TFLint..."
tflint

# Validate the Terraform configuration for syntax errors
echo "Validating Terraform configuration..."
terraform validate

# First terraform apply to create shared resources like Artifact Registry and Cloud Build Service Account
echo "--- Applying initial Terraform configuration to create shared resources (without Cloud Run deployment) ---"
terraform apply -auto-approve \
  -var="deploy_cloud_run=false" \
  -var="firestore_database_name=${FIRESTORE_DATABASE_NAME}" \
  -var="kms_project_id=${KMS_PROJECT_ID}" \
  -var="deploy_timestamp=$(date +%s)"

# Retrieve outputs that are now guaranteed to exist
CLOUDBUILD_SA_NAME=$(terraform output -raw cloud_build_service_account_name)
REPOSITORY_ID=$(terraform output -raw repository_id)

# --- Build & Push Images ---
for service in "$@"
do
  if [ "$service" = "auth-ui" ]; then
    echo "--- Building and Pushing Application Image to Artifact Registry (auth-ui) ---"
    cd ../auth-ui # Navigate to the application code

    IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${AUTH_UI_SERVICE_NAME}"
    LOG_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-logs"
    SOURCE_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-source/source.tgz"

    # Submit the build
    gcloud builds submit --tag "${IMAGE_URL}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="${LOG_BUCKET_URI}" --gcs-source-staging-dir="${SOURCE_BUCKET_URI}" .

    sleep 10
    cd ../terraform # Return to the terraform directory

  elif [ "$service" = "users-api" ]; then
    echo "--- Building and Pushing Users API Image to Artifact Registry (users-api) ---"
    cd ../users-api # Navigate to the application code

    IMAGE_URL="${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${USERS_API_SERVICE_NAME}"
    LOG_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-logs"
    SOURCE_BUCKET_URI="gs://${PROJECT_ID}-cloudbuild-source/source.tgz"

    # Submit the build
    gcloud builds submit --tag "${IMAGE_URL}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="${LOG_BUCKET_URI}" --gcs-source-staging-dir="${SOURCE_BUCKET_URI}" .

    sleep 10
    cd ../terraform # Return to the terraform directory
  else
    echo "Invalid service: $service. Available services: auth-ui, users-api"
    exit 1
  fi
done

# --- Deploy Cloud Run Services with Updated Images ---
echo "--- Deploying Cloud Run Services with updated images ---"
# Terraform will automatically detect which image has been updated and only
# deploy the service with the new image.
terraform apply -auto-approve \
  -var="deploy_cloud_run=true" \
  -var="firestore_database_name=${FIRESTORE_DATABASE_NAME}" \
  -var="kms_project_id=${KMS_PROJECT_ID}" \
  -var="deploy_timestamp=$(date +%s)"

# --- Post-Deployment Tests ---
echo "--- Running Post-Deployment Tests ---"
source ./test/run-tests.sh

echo "--- Deployment and Testing Complete ---"
