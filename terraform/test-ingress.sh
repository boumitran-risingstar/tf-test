#!/bin/bash
set -e
cd "$(dirname "$0")"

# Get the necessary outputs from Terraform
service_name=$(terraform output -raw service_name)
use_lb=$(terraform output -raw use_load_balancer)
region=$(terraform output -raw gcp_region)

if [[ -z "$service_name" || -z "$use_lb" || -z "$region" ]]; then
  echo "Error: Could not retrieve necessary outputs from Terraform."
  exit 1
fi

echo "Verifying Cloud Run ingress settings for service: $service_name"

# Get the current ingress setting of the Cloud Run service
current_ingress=$(gcloud run services describe $service_name --region $region --format 'value(ingress)')

if [[ "$use_lb" == "true" ]]; then
  expected_ingress="INTERNAL_LOAD_BALANCER"
  echo "Load balancer is enabled. Expecting ingress to be $expected_ingress."
else
  expected_ingress="ALL"
  echo "Load balancer is not enabled. Expecting ingress to be $expected_ingress."
fi

if [[ "$current_ingress" == "$expected_ingress" ]]; then
  echo "Ingress setting is correct: $current_ingress"
  echo "Test passed!"
  exit 0
else
  echo "Ingress setting is incorrect."
  echo "Expected: $expected_ingress"
  echo "Actual: $current_ingress"
  echo "Test failed."
  exit 1
fi
