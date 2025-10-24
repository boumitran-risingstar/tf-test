#!/bin/bash
set -e

# This script automates the deployment of the Mouth Metrics application.

# --- Configuration ---

# Navigate to the Terraform directory.
cd terraform

# Extract variables from Terraform configuration files.
PROJECT_ID=$(grep 'project_id' terraform.tfvars | awk -F'"' '{print $2}')
GCP_REGION=$(grep -A 2 'gcp_region' variables.tf | grep 'default' | awk -F'"' '{print $2}')
REPOSITORY_ID=$(grep -A 2 'repository_id' variables.tf | grep 'default' | awk -F'"' '{print $2}')
IMAGE_NAME=$(grep -A 2 'image_name' variables.tf | grep 'default' | awk -F'"' '{print $2}')

# Construct the full image name.
IMAGE_URL="$GCP_REGION-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_ID/$IMAGE_NAME:latest"

# --- Deployment Steps ---

# 1. Run validation and linting tests
# This script runs terraform init, validate, and tflint.
echo "Running validation and linting..."
./test.sh

# 2. Build and Push the Docker Image
# This command uses Google Cloud Build to build the Docker image and push it to the Artifact Registry.

echo "Building and pushing the Docker image to $IMAGE_URL..."
gcloud builds submit --tag "$IMAGE_URL" ../src

# 3. Apply Terraform Configuration
# This command creates or updates the infrastructure defined in the .tf files.

echo "Applying Terraform configuration..."
terraform apply -auto-approve

echo "Deployment completed successfully!"
