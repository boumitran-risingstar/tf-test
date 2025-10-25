#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the central configuration
source ./config.sh

# --- Initialize Terraform and Synchronize State ---
echo "--- Initializing Terraform and Synchronizing State ---"
cd terraform

# Create a terraform.tfvars file
echo "Creating terraform.tfvars file..."
cat <<EOT > terraform.tfvars
project_id = "$PROJECT_ID"
app_name = "$APP_NAME"
domain_name = "$DOMAIN_NAME"
gcp_region = "$GCP_REGION"
use_load_balancer = $USE_LOAD_BALANCER
deploy_user_email = "$DEPLOY_USER_EMAIL"
image_tag = "$IMAGE_TAG"
EOT

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# --- Creating Artifact Registry Repository ---
echo "--- Creating Artifact Registry Repository ---"
# Apply only the Artifact Registry to prevent chicken-and-egg issues
terraform apply -target=google_artifact_registry_repository.repository -auto-approve

# Wait for the repository to be fully provisioned
echo "Waiting 10 seconds for repository to provision..."
sleep 10

# --- Build and Push Container Image ---
echo "--- Building and Pushing Container Image ---"
cd ..
echo "Building and pushing new image..."
gcloud builds submit . --config=cloudbuild.yaml --substitutions=_TAG=$IMAGE_TAG,_GCR_HOSTNAME=${GCP_REGION}-docker.pkg.dev,_REPO_NAME=$(terraform -chdir=terraform output -raw repository_id),_IMAGE_NAME=$APP_NAME

# --- Deploying Remaining Infrastructure ---
echo "--- Deploying Remaining Infrastructure ---"
cd terraform

# Attempt to import the Identity Platform config to handle cases where it persists after deletion.
# If it doesn't exist, the command will fail, but '|| true' ensures the script continues.
echo "Attempting to import existing Identity Platform config..."
terraform import google_identity_platform_config.default projects/$PROJECT_ID/config || true

echo "Applying all infrastructure..."
terraform apply -auto-approve


# --- Post-Deployment Actions ---
echo "--- Running Post-Deployment ---"
APP_URL=$(terraform output -raw app_url)
echo "Application URL: $APP_URL"

echo "--- Deployment successful! ---"
