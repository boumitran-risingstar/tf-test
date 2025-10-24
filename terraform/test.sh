#!/bin/bash

# Exit on error
set -e

# Change to the terraform directory
cd "$(dirname "$0")"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init -input=false

# Validate the Terraform configuration
echo "Validating Terraform configuration..."
terraform validate

# Initialize tflint
echo "Initializing tflint..."
tflint --init

# Run tflint
echo "Running tflint..."
tflint

echo "Validation and linting successful!"
