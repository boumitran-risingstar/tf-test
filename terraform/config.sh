#!/bin/bash

# --- Central Configuration ---
# This file is the single source of truth for all configuration variables.

# GCP Project ID
export PROJECT_ID="tf-test-476002"

# Deploy User Email
export DEPLOY_USER_EMAIL="boumitran@32studio.org"

# Application Name
export APP_NAME="mouth-metrics"

# Service Name
export AUTH_UI_SERVICE_NAME="auth-ui"
export USERS_API_SERVICE_NAME="users-api"

# Domain Name
export DOMAIN_NAME="mouthmetrics.32studio.org"

# GCP Region
export GCP_REGION="us-central1"

# GCP APIs Endpoint
export GCP_APIS_ENDPOINT="googleapis.com"

# Image Tag
export IMAGE_TAG="latest"

# Use Load Balancer
export USE_LOAD_BALANCER="false"

# Firestore Database Name
export FIRESTORE_DATABASE_NAME="users"
