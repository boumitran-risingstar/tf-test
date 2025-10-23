
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.38.0"
    }
  }
}

provider "google" {
  project = "tf-test-476002"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
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

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}

resource "google_compute_network" "default" {
  name                    = "vps-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name          = "vps-subnetwork"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

resource "google_compute_subnetwork" "proxy_only" {
  name          = "proxy-only-subnet"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "hello-world-neg"
  region                = "us-central1"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
}

resource "google_compute_region_backend_service" "default" {
  name                            = "backend-service"
  region                          = "us-central1"
  protocol                        = "HTTP"
  timeout_sec                     = 30
  load_balancing_scheme           = "INTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }
}

resource "google_compute_region_url_map" "default" {
  name            = "url-map"
  region          = "us-central1"
  default_service = google_compute_region_backend_service.default.id
}

resource "google_compute_region_target_http_proxy" "default" {
  name    = "http-proxy"
  region  = "us-central1"
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_forwarding_rule" "default" {
  name                  = "forwarding-rule"
  region                = "us-central1"
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  target                = google_compute_region_target_http_proxy.default.id
  network               = google_compute_network.default.id
  subnetwork            = google_compute_subnetwork.default.id
}
