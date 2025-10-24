#!/bin/bash
set -e

# This script runs a series of post-deployment tests against the live application.
# It is designed to be run from within the 'terraform' directory.

# --- Test Execution ---

# This test ALWAYS runs to ensure the Cloud Run service has the correct ingress settings.
echo "----- Running Ingress Test -----"
chmod +x test-ingress.sh
./test-ingress.sh

# Now, check if the SSL certificate is active before running LB-dependent tests.
chmod +x check-lb-status.sh
if ./check-lb-status.sh; then
  echo "SSL certificate is active. Proceeding with all load balancer tests."
  
  echo "----- Running Health Check Test -----"
  chmod +x test-health.sh
  ./test-health.sh

  echo "----- Running WAF Test -----"
  chmod +x test-waf.sh
  ./test-waf.sh
  
  echo "----- Running Rate Limiting Test -----"
  chmod +x test-rate-limiting.sh
  ./test-rate-limiting.sh
else
  echo "Skipping Health Check, WAF, and Rate Limiting tests because SSL certificate is still provisioning."
fi

echo "All applicable tests completed successfully."
