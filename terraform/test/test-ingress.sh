#!/bin/bash
set -e

# This script tests the ingress settings of the Cloud Run service by checking its configuration directly.

# --- Ingress Test ---

# Get the necessary outputs and variables.
USE_LOAD_BALANCER=$(terraform output -raw use_load_balancer)
SERVICE_NAME=$(terraform output -raw service_name)
LOCATION=$(terraform output -raw location)
PROJECT_ID=$(terraform output -raw project_id)

# Determine the expected ingress setting
if [ "$USE_LOAD_BALANCER" = "true" ]; then
  EXPECTED_INGRESS="internal-and-cloud-load-balancing"
  echo "Load balancer is enabled. Expecting ingress to be '$EXPECTED_INGRESS'."
else
  EXPECTED_INGRESS="all"
  echo "Load balancer is not enabled. Expecting ingress to be '$EXPECTED_INGRESS'."
fi

# Poll for the ingress setting
MAX_ATTEMPTS=10
RETRY_DELAY=5 # in seconds

for (( i=1; i<=MAX_ATTEMPTS; i++ )); do
  echo "Checking actual ingress settings for service '$SERVICE_NAME' in '$LOCATION' (Attempt $i/$MAX_ATTEMPTS)..."
  ACTUAL_INGRESS=$(gcloud run services describe "$SERVICE_NAME" --region "$LOCATION" --project "$PROJECT_ID" --format="value(metadata.annotations['run.googleapis.com/ingress'])" 2>/dev/null || true)
  echo "Actual ingress setting is '$ACTUAL_INGRESS'."

  if [ "$ACTUAL_INGRESS" = "$EXPECTED_INGRESS" ]; then
    echo "Ingress test PASSED. The ingress setting is correctly configured."
    exit 0
  fi

  echo "Waiting for $RETRY_DELAY seconds before retrying..."
  sleep $RETRY_DELAY
done

echo "Ingress test FAILED. Expected '$EXPECTED_INGRESS' but got '$ACTUAL_INGRESS'."
exit 1
