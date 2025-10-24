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

# Construct the full image name for Google Cloud Build.
IMAGE_URL="$GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_ID/$IMAGE_NAME:latest"

# --- Deployment Steps ---

# 1. Initialize Terraform and run validation tests
echo "Initializing Terraform and running validation..."
terraform init
tflint --init
tflint
terraform validate

# 2. Apply Terraform (First Pass)
# This creates the Artifact Registry repository and other infrastructure.
# We add '|| true' to this command because we expect it to fail. The Cloud Run
# service cannot be created until the image exists, but the repository will be.
echo "Applying Terraform to create infrastructure (pass 1/2)..."
terraform apply -auto-approve -var="deploy_user_email=$DEPLOY_USER_EMAIL" || true

# 3. Build and Push the Docker Image
# This command uses Google Cloud Build to build the Docker image and push it
# to the now-existing Artifact Registry repository.
echo "Building and pushing the Docker image to $IMAGE_URL..."
gcloud builds submit --tag "$IMAGE_URL" ../src

# 4. Apply Terraform (Second Pass)
# This second apply updates the Cloud Run service with the newly published image.
echo "Applying Terraform to deploy the new image (pass 2/2)..."
terraform apply -auto-approve -var="deploy_user_email=$DEPLOY_USER_EMAIL"

# 5. Run Post-Deployment Tests
# This script runs a series of tests against the live application.
echo "Running post-deployment tests..."
chmod +x run-tests.sh
./run-tests.sh

echo "Deployment and all tests completed successfully!"
