#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "Running post-deployment tests..."

echo -e "\n----- Running Health Check Test -----"
./test-health.sh

echo -e "\n----- Running Ingress Test -----"
./test-ingress.sh

echo -e "\n----- Running WAF Test -----"
./test-waf.sh

echo -e "\n----- Running Rate Limiting Test -----"
./test.sh

echo -e "\nAll post-deployment tests passed!"
