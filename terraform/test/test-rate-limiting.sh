#!/bin/bash
set -e

# This script tests that the rate limiting is correctly configured.

TEST_URL=$1
CURL_OPTS=$2

# --- Test Rate Limiting ---
echo "Testing rate limiting on $TEST_URL..."

# This test attempts to trigger the rate limit.
# It sends requests until it receives a 429 "Too Many Requests" status.
# A successful test is one that is successfully blocked.
for i in {1..120}; do
  RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" $CURL_OPTS "$TEST_URL/")
  echo "Request $i: Status $RESPONSE_CODE"

  if [ "$RESPONSE_CODE" -eq 429 ]; then
    echo "Rate limiting test PASSED. Received expected 429 status."
    exit 0
  fi
  # Small sleep to avoid overwhelming the client machine
  sleep 0.1
done

echo "Rate limiting test FAILED. Did not receive a 429 status after 120 requests."
exit 1
