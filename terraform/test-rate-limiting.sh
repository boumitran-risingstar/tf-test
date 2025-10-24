#!/bin/bash
set -e

# This script tests that the rate limiting is correctly configured.

# --- Rate Limiting Test ---

# Get the necessary outputs from Terraform.
USE_LOAD_BALANCER=$(terraform output -raw use_load_balancer)
DOMAIN_NAME=$(terraform output -raw domain_name)

if [ "$USE_LOAD_BALANCER" != "true" ]; then
  echo "Load balancer and rate limiting are not enabled. Skipping rate limiting test."
  exit 0
fi

LB_IP_ADDRESS=$(terraform output -raw lb_ip_address)

if [ "$LB_IP_ADDRESS" = "N/A" ]; then
  echo "Load balancer IP is not available. Skipping rate limiting test."
  exit 1
fi

# --- Test Rate Limiting ---
echo "Testing rate limiting..."

# Send 120 requests in quick succession to trigger the rate limit.
for i in {1..120}; do
  # The last request's response code will be captured.
  RESPONSE_CODE=$(curl --resolve "$DOMAIN_NAME:443:$LB_IP_ADDRESS" -s -o /dev/null -w "%{http_code}" "https://$DOMAIN_NAME/")
  echo "Request $i: Status $RESPONSE_CODE"

  # If we get a 429, we can stop early.
  if [ "$RESPONSE_CODE" -eq 429 ]; then
    break
  fi

  # Small sleep to avoid overwhelming the client machine.
  sleep 0.1
done

if [ "$RESPONSE_CODE" -ne 429 ]; then
  echo "Rate limiting test failed. Expected 429, got $RESPONSE_CODE"
  exit 1
fi

echo "Rate limiting test passed."
