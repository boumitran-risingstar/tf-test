####################################################################################
# Provider
####################################################################################

provider "google" {
  project = var.project_id
  region  = var.region
}

####################################################################################
# APIs
####################################################################################

# Resource manager is needed for the cloud build trigger to get the project number
resource "google_project_service" "project" {
  service = "cloudresourcemanager.googleapis.com"
}

# Enable the APIs needed for the project
resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "iap" {
  service = "iap.googleapis.com"
}

# Permissions for the User running the script
resource "google_project_iam_member" "cloud_build_editor_user" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "user:${var.deploy_user_email}"
}

# Permissions for the Service Account
resource "google_project_iam_member" "service_usage_consumer" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_build_editor_sa" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "artifact_registry_admin_sa" {
  project = var.project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "cloud_run_admin_sa" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "storage_admin_sa" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "service_account_user_sa" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

####################################################################################
# Artifact Registry
####################################################################################

resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = local.repository_id
  description   = "Docker repository for ${var.app_name}"
  format        = "DOCKER"
}

####################################################################################
# Cloud Build
####################################################################################

resource "google_cloudbuild_trigger" "deploy_trigger" {
  project = var.project_id
  name    = "deploy-${local.service_name}"

  github {
    owner = "ask-gemini"
    name  = "terraform-sample-app"
    push {
      branch = "^main$"
    }
  }

  # This will match any changes in the auth-ui directory
  included_files = ["auth-ui/**"]

  substitutions = {
    _APP_NAME     = var.app_name
    _SERVICE_NAME = var.service_name
    _REGION       = var.region
    _PROJECT_ID   = var.project_id
  }

  filename = "cloudbuild.yaml"
}
