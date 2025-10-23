
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
    null = {
      source = "hashicorp/null"
    }
  }
}

variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

provider "time" {}

provider "null" {}


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

resource "google_artifact_registry_repository" "repository" {
  location      = "us-central1"
  repository_id = "hello-world-repo"
  description   = "Repository for the Hello World application."
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "null_resource" "build_and_push_image" {
  provisioner "local-exec" {
    command = "gcloud builds submit --tag us-central1-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.repository.repository_id}/hello-world-image:latest ../src"
  }

  depends_on = [google_artifact_registry_repository.repository]
}

resource "time_sleep" "wait_for_image" {
  create_duration = "180s"

  depends_on = [null_resource.build_and_push_image]
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

  depends_on = [time_sleep.wait_for_image]
}

# Allow unauthenticated access to the Cloud Run service.
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  provider = google-beta
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"

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

resource "google_compute_security_policy" "canned_policy" {
  provider    = google-beta
  name        = "hello-world-policy"
  description = "Basic WAF and rate limiting policy"

  rule {
    action   = "deny(403)"
    priority = 1000
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    description = "XSS Protection"
  }

  rule {
    action   = "deny(403)"
    priority = 1100
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    description = "SQLi Protection"
  }

  # Rule for rate limiting
  rule {
    action   = "throttle"
    priority = 1500
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count = 100
        interval_sec = 60
      }
    }
    description = "Rate limit to 100 requests per minute per IP"
  }

  # Default rule to allow all other traffic
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow"
  }
}

resource "google_compute_backend_service" "backend_service" {
  provider = google-beta
  name      = "hello-world-backend-service"
  protocol  = "HTTP"
  port_name = "http"
  timeout_sec = 30
  security_policy = google_compute_security_policy.canned_policy.self_link
  enable_cdn = true

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

# --- Networking and SSL for HTTPS --- 

resource "google_compute_global_address" "static_ip" {
  provider = google-beta
  name = "hello-world-static-ip"
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  provider = google-beta
  name = "hello-world-ssl-cert"
  managed {
    domains = ["mouthmetrics.32studio.org"]
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  provider = google-beta
  name    = "hello-world-https-proxy"
  url_map = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  provider = google-beta
  name       = "hello-world-https-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.static_ip.address
}

resource "google_compute_target_http_proxy" "http_proxy" {
  provider = google-beta
  name    = "hello-world-http-proxy"
  url_map = google_compute_url_map.url_map.id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  provider = google-beta
  name       = "hello-world-http-forwarding-rule"
  target     = google_compute_target_http_proxy.http_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.static_ip.address
}


# --- Outputs --- 

output "lb_ip_address" {
  description = "The IP address of the load balancer."
  value       = google_compute_global_address.static_ip.address
}
