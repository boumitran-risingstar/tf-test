#!/bin/bash
set -e

# This script tests that the Web Application Firewall (WAF) is correctly blocking common attacks.

# --- WAF Test ---

# Get the necessary outputs from Terraform.
USE_LOAD_BALANCER=$(terraform output -raw use_load_balancer)
DOMAIN_NAME=$(terraform output -raw domain_name)

if [ "$USE_LOAD_BALANCER" != "true" ]; then
  echo "Load balancer and WAF are not enabled. Skipping WAF test."
  exit 0
fi

LB_IP_ADDRESS=$(terraform output -raw lb_ip_address)

if [ "$LB_IP_ADDRESS" = "N/A" ]; then
  echo "Load balancer IP is not available. Skipping WAF test."
  exit 1
fi

# --- Test XSS Protection ---
echo "Testing WAF for XSS protection..."
XSS_ATTACK_URL="https://$DOMAIN_NAME/?param=<script>alert('xss')</script>"

# Use --resolve to directly test the load balancer
RESPONSE_CODE_XSS=$(curl --resolve "$DOMAIN_NAME:443:$LB_IP_ADDRESS" -s -o /dev/null -w "%{http_code}" "$XSS_ATTACK_URL")

if [ "$RESPONSE_CODE_XSS" -ne 403 ]; then
  echo "WAF XSS test failed. Expected 403, got $RESPONSE_CODE_XSS"
  exit 1
fi

echo "XSS protection test passed."

# --- Test SQLi Protection ---
echo "Testing WAF for SQLi protection..."
SQLI_ATTACK_URL="https://$DOMAIN_NAME/?param=1%20OR%201=1"

RESPONSE_CODE_SQLI=$(curl --resolve "$DOMAIN_NAME:443:$LB_IP_ADDRESS" -s -o /dev/null -w "%{http_code}" "$SQLI_ATTACK_URL")

if [ "$RESPONSE_CODE_SQLI" -ne 403 ]; then
  echo "WAF SQLi test failed. Expected 403, got $RESPONSE_CODE_SQLI"
  exit 1
fi

echo "SQLi protection test passed."

echo "WAF test passed successfully."
