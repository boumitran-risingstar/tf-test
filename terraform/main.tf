
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.38.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.38.0"
    }
  }
}

provider "google" {
  project = "tf-test-476002"
}

provider "google-beta" {
  project = "tf-test-476002"
}

data "google_project" "project" {}

resource "google_project_service" "run" {
  service                    = "run.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "artifactregistry" {
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_artifact_registry_repository" "repository" {
  location      = "us-central1"
  repository_id = "hello-world-repo"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "hello-world-service"
  location = "us-central1"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/${google_artifact_registry_repository.repository.project}/hello-world-repo/hello-world-image:latest"
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "hello-world-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

resource "google_compute_backend_service" "backend_service" {
  name      = "hello-world-backend-service"
  protocol  = "HTTP"
  port_name = "http"
  timeout_sec = 30
  enable_cdn = true

  log_config {
    enable = true
    sample_rate = 1.0
  }

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "hello-world-url-map"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "hello-world-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "hello-world-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}

output "load_balancer_ip" {
  description = "The IP address of the Global Load Balancer."
  value       = google_compute_global_forwarding_rule.forwarding_rule.ip_address
}
