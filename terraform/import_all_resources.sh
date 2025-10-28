#!/bin/bash
set -e

if [ -f "./config.sh" ]; then
  source ./config.sh
else
  echo "Error: Configuration file './config.sh' not found."
  exit 1
fi

terraform init

import_if_missing() {
  local resource_address=$1
  local resource_id=$2

  if [ -f "terraform.tfstate" ] && [ -s "terraform.tfstate" ] && terraform state list | grep -q "^${resource_address}$"; then
    echo "Resource ${resource_address} already in state. Skipping import."
    return
  fi

  echo "Attempting to import ${resource_address}..."
  terraform import "${resource_address}" "${resource_id}" || true
}

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
import_if_missing "google_cloud_run_v2_service.default[0]" "projects/$PROJECT_ID/locations/$GCP_REGION/services/${AUTH_UI_SERVICE_NAME}"
import_if_missing "google_cloud_run_v2_service.users_api[0]" "projects/$PROJECT_ID/locations/$GCP_REGION/services/${USERS_API_SERVICE_NAME}"
if [ -n "$DOMAIN_NAME" ]; then
  import_if_missing "google_cloud_run_domain_mapping.default[0]" "locations/$GCP_REGION/namespaces/$PROJECT_ID/domainmappings/$DOMAIN_NAME"
fi
