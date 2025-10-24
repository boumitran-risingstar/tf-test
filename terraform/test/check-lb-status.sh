#!/bin/bash
set -e

# This script checks if load balancer-dependent tests should be skipped.
# Exits with 0 if tests should RUN.
# Exits with 1 if tests should be SKIPPED.

# By default, tests should run.
PROCEED=0

if [ "$(terraform output -raw use_load_balancer)" == "true" ]; then
  echo "Load balancer is enabled. Checking SSL certificate status..."
  APP_NAME=$(grep 'app_name' terraform.tfvars | awk -F'\"' '{print $2}')
  CERTIFICATE_NAME="${APP_NAME}-ssl-cert"
  
  # Check the certificate status.
  CERT_STATUS=$(gcloud compute ssl-certificates describe $CERTIFICATE_NAME --global --format="get(managed.status)" || echo "UNKNOWN")
  
  if [ "$CERT_STATUS" = "PROVISIONING" ]; then
    echo "SSL certificate is still provisioning."
    PROCEED=1 # Signal to SKIP tests
  else
    echo "SSL certificate status is '$CERT_STATUS'. Proceeding with tests."
  fi
fi

exit $PROCEED
