#!/bin/bash
set -e
cd "$(dirname "$0")"

# Get the URL from Terraform output
url=$(terraform output -raw app_url)
use_lb=$(terraform output -raw use_load_balancer)

if [[ "$use_lb" == "false" ]]; then
  echo "Skipping rate limiting test because load balancer is not enabled."
  exit 0
fi

if [[ -z "$url" ]]; then
  echo "Error: app_url not found in terraform output."
  echo "Please add the following to your terraform/main.tf:"
  echo ''
  echo 'output "app_url" {'
  echo '  value = module.app.url'
  echo '}'
  exit 1
fi

echo "Testing rate limiting on $url"
echo "Sending 120 requests..."

# Send 120 requests and store the HTTP status code
# of each response in an array.
status_codes=()
for i in {1..120}; do
  status_codes+=($(curl -s -o /dev/null -w "%{http_code}" "$url" || true))
  sleep 0.2 # sleep to avoid overwhelming the client machine
done

# Count the number of 200 and 429 responses
success_count=$(grep -o "200" <<< "${status_codes[*]}" | wc -l)
ratelimited_count=$(grep -o "429" <<< "${status_codes[*]}" | wc -l)

echo "Success (200) count: $success_count"
echo "Rate limited (429) count: $ratelimited_count"

# Check if we got both 200s and 429s.
# The exact number can vary, so we just check that we were
# rate limited at some point.
if (( success_count > 0 && ratelimited_count > 0 )); then
  echo "Test passed: Rate limiting is working as expected."
  exit 0
else
  echo "Test failed: Rate limiting is NOT working as expected."
  exit 1
fi
