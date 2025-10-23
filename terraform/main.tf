variable "project_id" {
  description = "The project ID to host the service in"
  default     = "tf-test-476002"
}

variable "region" {
  description = "The region to host the service in"
  default     = "us-central1"
}

terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.6.0"
    }
  }
}

provider "google-beta" {
  project = var.project_id
}

data "google_project" "project" {
  provider = google-beta
}

resource "google_project_service" "run" {
  provider                   = google-beta
  service                    = "run.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "artifactregistry" {
  provider                   = google-beta
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "apigateway" {
  provider                   = google-beta
  service                    = "apigateway.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "servicecontrol" {
  provider                   = google-beta
  service                    = "servicecontrol.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_iam_member" "api_gateway_invoker" {
  provider = google-beta
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-apigateway.iam.gserviceaccount.com"
}

resource "google_artifact_registry_repository" "repository" {
  provider      = google-beta
  location      = var.region
  repository_id = "hello-world-repo"
  format        = "DOCKER"
  depends_on = [
    google_project_service.artifactregistry,
    google_project_service.run
  ]
}

resource "google_cloud_run_v2_service" "default" {
  provider = google-beta
  name     = "hello-world-service"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repository.repository_id}/hello-world-image:latest"
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  depends_on = [
    google_project_service.run
  ]
}

resource "google_api_gateway_api" "api" {
  provider   = google-beta
  api_id = "hello-world-api"
  depends_on = [
    google_project_service.apigateway
  ]
}

resource "google_api_gateway_api_config" "api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id_prefix = "hello-world-api-config-"

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = base64encode(templatefile("${path.module}/spec.yaml.tftpl", { service_url = google_cloud_run_v2_service.default.uri }))
    }
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    google_api_gateway_api.api
  ]
}

resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = "hello-world-gateway"
  region     = var.region
  depends_on = [
    google_api_gateway_api_config.api_config
  ]
}

output "gateway_url" {
  value = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}
