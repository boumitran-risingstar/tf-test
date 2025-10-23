terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.8.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
  default     = "hello-world-service"
}

variable "api_id" {
  description = "The ID of the API."
  type        = string
  default     = "hello-world-api"
}

variable "api_config_id" {
  description = "The ID of the API config."
  type        = string
  default     = "hello-world-api-config"
}

variable "gateway_id" {
  description = "The ID of the API Gateway."
  type        = string
  default     = "hello-world-gateway"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "apigateway" {
  service = "apigateway.googleapis.com"
}

resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = "hello-world-repo"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repository.repository_id}/hello-world:latest"
    }
  }

  depends_on = [google_project_service.run]
}

resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id = var.api_id
  project = var.project_id
}

resource "google_api_gateway_api_config" "api_config" {
  provider = google-beta
  api          = google_api_gateway_api.api.api_id
  api_config_id = "${var.api_config_id}-${substr(sha1(templatefile("${path.module}/spec.yaml.tftpl", { service_url = google_cloud_run_v2_service.default.uri })), 0, 7)}"
  project      = var.project_id
  display_name = "Hello World API Config"

  lifecycle {
    create_before_destroy = true
  }

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = base64encode(templatefile("${path.module}/spec.yaml.tftpl", {
        service_url = google_cloud_run_v2_service.default.uri
      }))
    }
  }

  depends_on = [google_project_service.apigateway]
}

resource "google_api_gateway_gateway" "gateway" {
  provider = google-beta
  api_config = google_api_gateway_api_config.api_config.id
  gateway_id = var.gateway_id
  region     = var.region
  project    = var.project_id
}

data "google_project" "project" {}

resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-apigateway.iam.gserviceaccount.com"
}

output "gateway_url" {
  value = "https://${google_api_gateway_gateway.gateway.default_hostname}"
}
