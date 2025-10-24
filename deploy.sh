#!/bin/bash
set -e

# This script automates the deployment of the Mouth Metrics application.

# --- Configuration ---

# Navigate to the Terraform directory.
cd terraform

# Extract variables from Terraform configuration files.
PROJECT_ID=$(grep 'project_id' terraform.tfvars | awk -F'"' '{print $2}')
GCP_REGION=$(awk '/variable "gcp_region"/, /}/' variables.tf | grep 'default' | awk -F'"' '{print $2}')
APP_NAME=$(grep 'app_name' terraform.tfvars | awk -F'"' '{print $2}')
DEPLOY_USER_EMAIL=$(gcloud config get-value account)

# Replicate the logic from locals.tf to construct resource names.
REPOSITORY_ID="${APP_NAME}-repo"
IMAGE_NAME="${APP_NAME}-image"

# Get the short hash of the latest git commit to use as the image tag.
IMAGE_TAG=$(git rev-parse --short HEAD)

# Construct the full image URL.
IMAGE_URL="$GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_ID/$IMAGE_NAME"

# --- Deployment Steps ---

# 1. Initialize Terraform and run validation tests
echo "Initializing Terraform and running validation..."
terraform init
tflint --init
tflint
terraform validate

# 2. Check if the image already exists
if gcloud artifacts docker images describe "${IMAGE_URL}:${IMAGE_TAG}" &> /dev/null; then
  echo "Image with tag ${IMAGE_TAG} already exists. Skipping build."
else
  # 3. Build and Push the Docker Image
  echo "Building and pushing the Docker image to ${IMAGE_URL}:${IMAGE_TAG}..."
  gcloud builds submit --tag "${IMAGE_URL}:${IMAGE_TAG}" ../src
fi

# 4. Apply Terraform
# This creates the necessary infrastructure and deploys the application.
echo "Applying Terraform to deploy the new image..."
terraform apply -auto-approve -var="deploy_user_email=$DEPLOY_USER_EMAIL" -var="image_tag=$IMAGE_TAG"

# 5. Run Post-Deployment Tests
# This script runs a series of tests against the live application.
echo "Running post-deployment tests..."
chmod +x test/run-tests.sh
./test/run-tests.sh

echo "Deployment and all tests completed successfully!"
