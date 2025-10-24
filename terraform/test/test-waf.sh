#!/bin/bash
set -e

# This script tests that the Web Application Firewall (WAF) is correctly blocking common attacks.

TEST_URL=$1
CURL_OPTS=$2

# --- Test XSS Protection ---
echo "Testing WAF for XSS protection..."
XSS_ATTACK_URL="$TEST_URL/?param=<script>alert('xss')</script>"

RESPONSE_CODE_XSS=$(curl -s -o /dev/null -w "%{http_code}" $CURL_OPTS "$XSS_ATTACK_URL")

if [ "$RESPONSE_CODE_XSS" -ne 403 ]; then
  echo "WAF XSS test FAILED. Expected 403, got $RESPONSE_CODE_XSS"
  exit 1
fi

echo "XSS protection test PASSED."

# --- Test SQLi Protection ---
echo "Testing WAF for SQLi protection..."
SQLI_ATTACK_URL="$TEST_URL/?param=1%20OR%201=1"

RESPONSE_CODE_SQLI=$(curl -s -o /dev/null -w "%{http_code}" $CURL_OPTS "$SQLI_ATTACK_URL")

if [ "$RESPONSE_CODE_SQLI" -ne 403 ]; then
  echo "WAF SQLi test FAILED. Expected 403, got $RESPONSE_CODE_SQLI"
  exit 1
fi

echo "SQLi protection test PASSED."

echo "WAF test PASSED successfully."
