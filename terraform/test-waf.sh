#!/bin/bash
set -e
cd "$(dirname "$0")"

# Get the URL and LB status from Terraform output
url=$(terraform output -raw service_url)
use_lb=$(terraform output -raw use_load_balancer)

if [[ "$use_lb" == "false" ]]; then
  echo "Skipping WAF test because load balancer is not enabled."
  exit 0
fi

# If using the LB, the URL is different
if [[ "$use_lb" == "true" ]]; then
  domain=$(terraform output -raw domain_name)
  url="https://${domain}"
fi

if [[ -z "$url" ]]; then
  echo "Error: service_url or domain_name not found in terraform output."
  exit 1
fi

echo "Testing WAF rules on $url"

# Test for XSS protection
echo "Testing for XSS protection..."
# A simple XSS payload in a query parameter
xss_payload="/?q=<script>alert('xss')</script>"
# We expect a 403 Forbidden response from the WAF
xss_status_code=$(curl -s -o /dev/null -w "%{http_code}" "${url}${xss_payload}" || true)

if [[ "$xss_status_code" == "403" ]]; then
  echo "XSS test passed: Request was blocked with status code 403."
else
  echo "XSS test failed: Expected status code 403, but got $xss_status_code."
  exit 1
fi

# Test for SQLi protection
echo "Testing for SQLi protection..."
# A simple SQLi payload, URL encoded: ' OR '1'='1
sqli_payload="/?id=1'%20OR%20'1'='1'"
# We expect a 403 Forbidden response from the WAF
sqli_status_code=$(curl -s -o /dev/null -w "%{http_code}" "${url}${sqli_payload}" || true)

if [[ "$sqli_status_code" == "403" ]]; then
  echo "SQLi test passed: Request was blocked with status code 403."
else
  echo "SQLi test failed: Expected status code 403, but got $sqli_status_code."
  exit 1
fi

echo "All WAF tests passed!"
exit 0
