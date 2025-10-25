#!/bin/bash
set -e

# This script runs a series of post-deployment tests against the live application.
# It is designed to be run from within the 'terraform/test' directory.

echo "--- Getting Test Runner's Public IP ---"
RUNNER_IP=$(curl -s ifconfig.me)
echo "Test Runner's Public IP: $RUNNER_IP"
echo "------------------------------------"


# --- Test Configuration ---
# We need to go up one directory to run terraform commands
DOMAIN_NAME=$(cd .. && terraform output -raw domain_name)
LB_IP_ADDRESS=$(cd .. && terraform output -raw lb_ip_address)
USE_LOAD_BALANCER=$(cd .. && terraform output -raw use_load_balancer)

# Default test parameters
TEST_URL="https://$DOMAIN_NAME"
CURL_OPTS=""

# --- Test Execution ---

# This test ALWAYS runs to ensure the Cloud Run service has the correct ingress settings.
echo "----- Running Ingress Test -----"
chmod +x ./test-ingress.sh
./test-ingress.sh

if [ "$USE_LOAD_BALANCER" = "true" ]; then
  chmod +x ./check-lb-status.sh
  if ./check-lb-status.sh; then
    echo "SSL certificate is active. Testing against the domain name."
  else
    echo "SSL certificate is still provisioning. Testing against the load balancer IP."
    TEST_URL="http://$LB_IP_ADDRESS"
    CURL_OPTS="--resolve $DOMAIN_NAME:80:$LB_IP_ADDRESS --insecure"
  fi

  echo "----- Running Health Check Test -----"
  chmod +x ./test-health.sh
  ./test-health.sh "$TEST_URL" "$CURL_OPTS"

  echo "----- Running WAF Test -----"
  chmod +x ./test-waf.sh
  ./test-waf.sh "$TEST_URL" "$CURL_OPTS"

  # Add a 5-minute delay to allow Cloud Armor rules to propagate.
  echo "Waiting 5 minutes for Cloud Armor rules to propagate..."
  sleep 300

  echo "----- Running Rate Limiting Test -----"
  chmod +x ./test-rate-limiting.sh
  ./test-rate-limiting.sh "$TEST_URL" "$CURL_OPTS"
else
  echo "Load balancer is not enabled. Skipping all load balancer-related tests."
  exit 0
fi

echo "All applicable tests completed successfully."
