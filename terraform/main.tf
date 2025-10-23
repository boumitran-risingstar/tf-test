
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

# Enable necessary APIs
resource "google_project_service" "run" {
  service = "run.googleapis.com"
}
resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}
resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}


resource "google_artifact_registry_repository" "repository" {
  location      = "us-central1"
  repository_id = "hello-world-repo"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "hello-world-service"
  location = "us-central1"

  # Keep the service internal
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/${google_artifact_registry_repository.repository.project}/hello-world-repo/hello-world-image:latest"
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [google_project_service.run]
}

# Grant the Google-managed LB Service Account the permission to invoke the Cloud Run service.
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  project  = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  # This is the identity of the Google Cloud Load Balancer service agent.
  member   = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-loadbalancing.iam.gserviceaccount.com"
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "hello-world-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
  depends_on = [google_project_service.compute]
}


resource "google_compute_backend_service" "backend_service" {
  name      = "hello-world-backend-service"
  protocol  = "HTTP"
  port_name = "http"
  timeout_sec = 30
  # No complex authentication blocks needed here.

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
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
