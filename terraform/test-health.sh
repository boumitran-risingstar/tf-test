#!/bin/bash
set -e

# This script performs a single health check on the application.
# It's intended to be called by a runner script that handles retries or conditional execution.

# --- Health Check ---

# Get the necessary outputs from Terraform.
USE_LOAD_BALANCER=$(terraform output -raw use_load_balancer)
APP_URL=$(terraform output -raw app_url)
DOMAIN_NAME=$(terraform output -raw domain_name)
LB_IP_ADDRESS=$(terraform output -raw lb_ip_address)

echo "Performing a single health check..."

REQUEST_SUCCESSFUL=false

if [ "$USE_LOAD_BALANCER" = "true" ]; then
  echo "--> Checking status via load balancer at $LB_IP_ADDRESS..."
  # Use --resolve to force curl to use the LB IP for the domain name over HTTPS.
  if curl -s --resolve "$DOMAIN_NAME:443:$LB_IP_ADDRESS" -L --fail "https://$DOMAIN_NAME/" -o /dev/null; then
    REQUEST_SUCCESSFUL=true
  fi
else
  echo "--> Checking status at $APP_URL..."
  if curl -s -L --fail "$APP_URL/" -o /dev/null; then
    REQUEST_SUCCESSFUL=true
  fi
fi

if [ "$REQUEST_SUCCESSFUL" = true ]; then
  echo "Health check passed!"
  exit 0
else
  echo "Health check failed."
  exit 1
fi
