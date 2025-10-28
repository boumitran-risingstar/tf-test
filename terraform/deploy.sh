#!/bin/bash
# --- Flexible and Resilient Deployment Script ---
# This script automates the deployment of the application's infrastructure,
# offering several flags for situation-based flexibility.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
if [ -f "./config.sh" ]; then
  source ./config.sh
else
  echo "Error: Configuration file './config.sh' not found."
  exit 1
fi

# --- Argument Parsing ---
NO_IMPORT=false
SKIP_BUILDS=false
SKIP_TESTS=false
CLEAN_STATE=false
SERVICES=()

for arg in "$@"; do
  case $arg in
    --no-import)
      NO_IMPORT=true
      shift
      ;;
    --skip-builds)
      SKIP_BUILDS=true
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --clean-state)
      CLEAN_STATE=true
      shift
      ;;
    *)
      SERVICES+=("$arg")
      shift
      ;;
  esac
done

if [ ${#SERVICES[@]} -eq 0 ]; then
  SERVICES=("auth-ui" "users-api")
fi
echo "--- Deploying the following services: ${SERVICES[@]} ---"

# --- Pre-flight Checks and State Management ---
if [ "$CLEAN_STATE" = true ] && [ "$NO_IMPORT" = false ]; then
    echo "--- Clearing local Terraform state for a clean import ---"
    rm -f terraform.tfstate terraform.tfstate.backup
fi

# Create terraform.tfvars file
source ./create-tfvars.sh

# Initialize Terraform
echo "--- Initializing Terraform... ---"
terraform init

# --- Function to conditionally import resources ---
import_if_missing() {
  local resource_address=$1
  local resource_id=$2

  if [ "$NO_IMPORT" = true ]; then
    return
  fi

  if [ -f "terraform.tfstate" ] && [ -s "terraform.tfstate" ] && terraform state list | grep -q "^${resource_address}$"; then
    echo "Resource ${resource_address} already in state. Skipping import."
    return
  fi

  echo "Attempting to import ${resource_address}..."
  terraform import "${resource_address}" "${resource_id}" || true
}

# --- State Synchronization ---
if [ "$NO_IMPORT" = false ]; then
    echo "--- Synchronizing Terraform state with existing GCP resources... ---"
    import_if_missing "google_identity_platform_config.default" "projects/$PROJECT_ID"
    import_if_missing "google_identity_platform_default_supported_idp_config.google" "projects/$PROJECT_ID/defaultSupportedIdpConfigs/google.com"
    import_if_missing "google_service_account.default" "projects/$PROJECT_ID/serviceAccounts/auth-ui-sa@$PROJECT_ID.iam.gserviceaccount.com"
    import_if_missing "google_service_account.users_api" "projects/$PROJECT_ID/serviceAccounts/users-api-sa@$PROJECT_ID.iam.gserviceaccount.com"
    import_if_missing "google_service_account.cloudbuild" "projects/$PROJECT_ID/serviceAccounts/cloud-build-sa@$PROJECT_ID.iam.gserviceaccount.com"
    import_if_missing "google_secret_manager_secret.firebase_service_account_key" "projects/$PROJECT_ID/secrets/firebase-service-account-key"
    import_if_missing "google_artifact_registry_repository.default" "projects/$PROJECT_ID/locations/$GCP_REGION/repositories/${APP_NAME}-docker-repo"
    import_if_missing 'google_firestore_database.database[0]' "projects/$PROJECT_ID/databases/$FIRESTORE_DATABASE_NAME"
    import_if_missing 'google_kms_key_ring.firestore_key_ring[0]' "projects/$KMS_PROJECT_ID/locations/$GCP_REGION/keyRings/${APP_NAME}-firestore-keyring"
    import_if_missing 'google_kms_crypto_key.firestore_cmek_key[0]' "projects/$KMS_PROJECT_ID/locations/$GCP_REGION/keyRings/${APP_NAME}-firestore-keyring/cryptoKeys/${APP_NAME}-firestore-cmek-key"
    # Import the Cloud Run services themselves
    import_if_missing "google_cloud_run_v2_service.default[0]" "projects/$PROJECT_ID/locations/$GCP_REGION/services/${AUTH_UI_SERVICE_NAME}"
    import_if_missing "google_cloud_run_v2_service.users_api[0]" "projects/$PROJECT_ID/locations/$GCP_REGION/services/${USERS_API_SERVICE_NAME}"
fi

# --- Lint & Validate ---
echo "--- Linting and Validating Terraform Configuration ---"
tflint --init
tflint
terraform validate

# --- Apply Phase 1: Shared Resources ---
echo "--- Applying Terraform configuration for shared resources ---"
terraform apply -auto-approve -var="deploy_cloud_run=false" -var="firestore_database_name=${FIRESTORE_DATABASE_NAME}" -var="kms_project_id=${KMS_PROJECT_ID}" -var="deploy_timestamp=$(date +%s)"

# --- Build & Push Images ---
if [ "$SKIP_BUILDS" = false ]; then
    echo "--- Building and Pushing Container Images ---"
    CLOUDBUILD_SA_NAME=$(terraform output -raw cloud_build_service_account_name)
    REPOSITORY_ID=$(terraform output -raw repository_id)
    
    for service in "${SERVICES[@]}"; do
        if [ "$service" = "auth-ui" ]; then
            echo "Building auth-ui service..."
            cd ../auth-ui
            gcloud builds submit --tag "${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${AUTH_UI_SERVICE_NAME}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="gs://${PROJECT_ID}-cloudbuild-logs" --gcs-source-staging-dir="gs://${PROJECT_ID}-cloudbuild-source/source.tgz" .
            cd ../terraform
        elif [ "$service" = "users-api" ]; then
            echo "Building users-api service..."
            cd ../users-api
            gcloud builds submit --tag "${GCP_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY_ID}/${USERS_API_SERVICE_NAME}" --service-account="${CLOUDBUILD_SA_NAME}" --gcs-log-dir="gs://${PROJECT_ID}-cloudbuild-logs" --gcs-source-staging-dir="gs://${PROJECT_ID}-cloudbuild-source/source.tgz" .
            cd ../terraform
        fi
    done
else
    echo "--- Skipping image builds as per --skip-builds flag. ---"
fi

# --- Apply Phase 2: Cloud Run Services ---
echo "--- Deploying Cloud Run services ---"
terraform apply -auto-approve -var="deploy_cloud_run=true" -var="firestore_database_name=${FIRESTORE_DATABASE_NAME}" -var="kms_project_id=${KMS_PROJECT_ID}" -var="deploy_timestamp=$(date +%s)"

# --- Post-Deployment Tests ---
if [ "$SKIP_TESTS" = false ]; then
    echo "--- Running Post-Deployment Tests ---"
    source ./test/run-tests.sh
else
    echo "--- Skipping post-deployment tests as per --skip-tests flag. ---"
fi

echo "--- Deployment and Testing Complete ---"
