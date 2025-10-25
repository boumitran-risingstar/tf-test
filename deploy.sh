#!/bin/bash
set -e

# --- Source Configuration ---
source ./config.sh

# --- Derived Configuration ---

# The name of the container image.
IMAGE_NAME="${APP_NAME}-image"

# The name of the Artifact Registry repository.
REPOSITORY_NAME="${APP_NAME}-repo"

# --- Script ---

echo "--- Activating Service Account ---"
gcloud auth activate-service-account --key-file=gcloud-service-key.json

# --- Terraform Initialization and State Synchronization ---

echo "--- Initializing Terraform and Synchronizing State ---"

# Navigate to the terraform directory
cd terraform

# Create a terraform.tfvars file from the central config
echo "Creating terraform.tfvars file..."
cat > terraform.tfvars <<EOF
project_id = "$PROJECT_ID"
deploy_user_email = "$DEPLOY_USER_EMAIL"
app_name = "$APP_NAME"
domain_name = "$DOMAIN_NAME"
gcp_region = "$GCP_REGION"
EOF

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Attempt to import existing resources to prevent conflicts.
echo "--- Attempting to import existing resources ---"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')

# Temporarily disable exit-on-error for the import commands
set +e

echo "Importing Identity Platform config (if it exists)..."
terraform import google_identity_platform_config.default "projects/$PROJECT_ID"

echo "Importing IAP brand (if it exists)..."
terraform import google_iap_brand.project_brand "projects/$PROJECT_ID/brands/$PROJECT_NUMBER"

# Re-enable exit-on-error
set -e
echo "--- Finished importing resources ---"


# --- Terraform Pre-Step: Create Artifact Registry ---

echo "--- Creating Artifact Registry Repository ---"
# Apply only the Artifact Registry repository
terraform apply -auto-approve -target=google_artifact_registry_repository.repository

# Wait for the repository to be ready
echo "Waiting 10 seconds for repository to provision..."
sleep 10

# Return to the root directory
cd ..

# --- Build and Push Container Image ---

echo "--- Building and Pushing Container Image ---"

# Check if an image with the same tag already exists
if gcloud artifacts docker images describe \
  "$GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:$IMAGE_TAG" \
  --repository="$REPOSITORY_NAME" \
  --location="$GCP_REGION" &> /dev/null; then
  echo "Image with tag $IMAGE_TAG already exists. Skipping build."
else
  echo "Building and pushing new image..."
  gcloud beta builds submit . --config cloudbuild.yaml --substitutions=_GCR_HOSTNAME=$GCP_REGION-docker.pkg.dev,_REPO_NAME=$REPOSITORY_NAME,_IMAGE_NAME=$IMAGE_NAME,_TAG=$IMAGE_TAG
fi

# --- Deploy Infrastructure ---

echo "--- Deploying Remaining Infrastructure ---"

# Navigate back to the terraform directory
cd terraform

# Apply all infrastructure
echo "Applying all infrastructure..."
terraform apply -auto-approve -var="image_tag=$IMAGE_TAG"

# --- Post-Deployment ---
echo "--- Running Post-Deployment ---"

# Get the URL of the application
APP_URL=$(terraform output -raw app_url)
echo "Application URL: $APP_URL"

# Run post-deployment tests
echo "Running post-deployment tests..."
cd ./test
./run-tests.sh
cd .. # back to terraform directory

# Return to root
cd ..

echo "--- Deployment successful! ---"
