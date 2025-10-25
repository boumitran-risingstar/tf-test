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
  gcloud builds submit . --config cloudbuild.yaml --substitutions=_GCR_HOSTNAME=$GCP_REGION-docker.pkg.dev,_REPO_NAME=$REPOSITORY_NAME,_IMAGE_NAME=$IMAGE_NAME,_TAG=$IMAGE_TAG
fi

# --- Deploy Infrastructure ---

echo "--- Deploying Infrastructure ---"

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
cd ..


echo "--- Deployment successful! ---"
