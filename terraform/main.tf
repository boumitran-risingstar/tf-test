
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

provider "google" {
  project = "tf-test-476002"
}

provider "google-beta" {
  project = "tf-test-476002"
}

provider "time" {}


resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "apigateway" {
  service = "apigateway.googleapis.com"
}

resource "google_project_service" "servicemanagement" {
  service = "servicemanagement.googleapis.com"
}

resource "google_project_service" "servicecontrol" {
  service = "servicecontrol.googleapis.com"
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

data "google_project" "project" {}

# Create a dedicated, user-managed service account for the load balancer.
resource "google_service_account" "invoker" {
  account_id   = "cloud-run-lb-invoker"
  display_name = "Cloud Run Load Balancer Invoker"
}


resource "google_artifact_registry_repository" "repository" {
  location      = "us-central1"
  repository_id = "hello-world-repo"
  description   = "Repository for the Hello World application."
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_cloud_run_v2_service" "default" {
  deletion_protection = false
  provider = google-beta
  name     = "hello-world-service"
  location = "us-central1"

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    containers {
      image = "us-central1-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.repository.repository_id}/hello-world-image:latest"
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [google_project_service.run]
}

# Grant our new, user-managed service account the role to invoke the Cloud Run service.
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  provider = google-beta
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = google_service_account.invoker.member

  depends_on = [google_cloud_run_v2_service.default]
}


resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider = google-beta
  name                  = "hello-world-neg"
  network_endpoint_type = "SERVERLESS"
  region                = "us-central1"
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
  depends_on = [google_cloud_run_v2_service.default]
}

resource "google_compute_backend_service" "backend_service" {
  provider = google-beta
  name      = "hello-world-backend-service"
  protocol  = "HTTP"
  port_name = "http"
  timeout_sec = 30

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg.id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_url_map" "url_map" {
  provider = google-beta
  name            = "hello-world-url-map"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_http_proxy" "http_proxy" {
  provider = google-beta
  name    = "hello-world-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  provider = google-beta
  name       = "hello-world-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
}
