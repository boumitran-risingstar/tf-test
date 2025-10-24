#!/bin/bash
set -e

# This script performs a single health check on the application.

TEST_URL=$1
CURL_OPTS=$2

echo "Performing health check on $TEST_URL..."

# The -L flag follows redirects, which is important for the HTTP to HTTPS redirect.
# The --fail flag causes curl to exit with an error code if the HTTP response is not 2xx.
if curl -s -L --fail $CURL_OPTS "$TEST_URL/" -o /dev/null; then
  echo "Health check PASSED!"
  exit 0
else
  echo "Health check FAILED."
  exit 1
fi
