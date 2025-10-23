#!/bin/bash
set -e
terraform -chdir=terraform init -upgrade
terraform -chdir=terraform apply -auto-approve