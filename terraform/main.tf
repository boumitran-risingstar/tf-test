
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
  location      = var.gcp_region
  repository_id = var.repository_id
  description   = "Repository for the Hello World application."
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "null_resource" "build_and_push_image" {
  provisioner "local-exec" {
    command = "gcloud builds submit --tag ${var.gcp_region}-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.repository.repository_id}/${var.image_name}:latest ../src"
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
  name     = var.service_name
  location = var.gcp_region

  ingress = var.use_load_balancer ? "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" : "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.repository.repository_id}/${var.image_name}:latest"
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
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name                  = var.neg_name
  network_endpoint_type = "SERVERLESS"
  region                = var.gcp_region
  cloud_run {
    service = google_cloud_run_v2_service.default.name
  }
  depends_on = [google_cloud_run_v2_service.default]
}

resource "google_compute_security_policy" "canned_policy" {
  count       = var.use_load_balancer ? 1 : 0
  provider    = google-beta
  name        = var.policy_name
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
  count     = var.use_load_balancer ? 1 : 0
  provider  = google-beta
  name      = var.backend_service_name
  protocol  = "HTTP"
  port_name = "http"
  timeout_sec = 30
  security_policy = google_compute_security_policy.canned_policy[0].self_link
  enable_cdn = true

  backend {
    group = google_compute_region_network_endpoint_group.serverless_neg[0].id
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_url_map" "url_map" {
  count           = var.use_load_balancer ? 1 : 0
  provider        = google-beta
  name            = var.url_map_name
  default_service = google_compute_backend_service.backend_service[0].id
}

# --- Networking and SSL for HTTPS --- 

resource "google_compute_global_address" "static_ip" {
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name     = var.static_ip_name
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name     = var.ssl_certificate_name
  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  count            = var.use_load_balancer ? 1 : 0
  provider         = google-beta
  name             = var.https_proxy_name
  url_map          = google_compute_url_map.url_map[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate[0].id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count      = var.use_load_balancer ? 1 : 0
  provider   = google-beta
  name       = var.https_forwarding_rule_name
  target     = google_compute_target_https_proxy.https_proxy[0].id
  port_range = "443"
  ip_address = google_compute_global_address.static_ip[0].address
}

resource "google_compute_target_http_proxy" "http_proxy" {
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name     = var.http_proxy_name
  url_map  = google_compute_url_map.url_map[0].id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  count      = var.use_load_balancer ? 1 : 0
  provider   = google-beta
  name       = var.http_forwarding_rule_name
  target     = google_compute_target_http_proxy.http_proxy[0].id
  port_range = "80"
  ip_address = google_compute_global_address.static_ip[0].address
}

# --- Cloud Run Domain Mapping --- 

resource "google_cloud_run_domain_mapping" "default" {
  count    = var.use_load_balancer ? 0 : 1
  provider = google-beta
  location = google_cloud_run_v2_service.default.location
  name     = var.domain_name

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.default.name
    force_override = true
  }
}


# --- Outputs --- 

output "lb_ip_address" {
  description = "The IP address of the load balancer (if created)."
  value       = var.use_load_balancer ? google_compute_global_address.static_ip[0].address : "N/A"
}

output "service_url" {
    description = "The URL of the Cloud Run service"
    value = google_cloud_run_v2_service.default.uri
}
