
provider "google" {
  project = var.project_id
  user_project_override = true
}

provider "google-beta" {
  project = var.project_id
  user_project_override = true
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

resource "google_project_iam_member" "project_iam_admin_sa" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

data "google_project" "project" {}

resource "google_artifact_registry_repository" "repository" {
  location      = var.gcp_region
  repository_id = local.repository_id
  description   = "Repository for the Mouth Metrics application."
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_storage_bucket_iam_member" "cloud_build_storage_admin" {
  bucket = "${data.google_project.project.project_id}_cloudbuild"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "cloud_build_service_account_storage_admin" {
  bucket = "${data.google_project.project.project_id}_cloudbuild"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_service_identity" "cloudbuild" {
  provider = google-beta
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "${local.service_name}-sa"
  display_name = "Service Account for ${local.service_name}"
}

resource "google_project_iam_member" "cloud_run_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_cloud_run_v2_service" "default" {
  deletion_protection = false
  provider = google-beta
  name     = local.service_name
  location = var.gcp_region

  ingress = var.use_load_balancer ? "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER" : "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run_sa.email
    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${data.google_project.project.project_id}/${google_artifact_registry_repository.repository.repository_id}/${local.image_name}:${var.image_tag}"
      ports {
        container_port = 80
      }
    }
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }
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
  name                  = local.neg_name
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
  name        = local.policy_name
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
    action   = "rate_based_ban"
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
      ban_duration_sec = 600
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
  name      = local.backend_service_name
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
  name            = local.url_map_name
  default_service = google_compute_backend_service.backend_service[0].id
}

# --- Networking and SSL for HTTPS --- 

resource "google_compute_global_address" "static_ip" {
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name     = local.static_ip_name
}

resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name     = local.ssl_certificate_name
  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_target_https_proxy" "https_proxy" {
  count            = var.use_load_balancer ? 1 : 0
  provider         = google-beta
  name             = local.https_proxy_name
  url_map          = google_compute_url_map.url_map[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate[0].id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  count      = var.use_load_balancer ? 1 : 0
  provider   = google-beta
  name       = local.https_forwarding_rule_name
  target     = google_compute_target_https_proxy.https_proxy[0].id
  port_range = "443"
  ip_address = google_compute_global_address.static_ip[0].address
}

resource "google_compute_target_http_proxy" "http_proxy" {
  count    = var.use_load_balancer ? 1 : 0
  provider = google-beta
  name     = local.http_proxy_name
  url_map  = google_compute_url_map.url_map[0].id
}

resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  count      = var.use_load_balancer ? 1 : 0
  provider   = google-beta
  name       = local.http_forwarding_rule_name
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

output "use_load_balancer" {
  description = "Whether the load balancer is enabled."
  value       = var.use_load_balancer
}

output "app_url" {
  description = "The application URL."
  value       = var.use_load_balancer ? "https://${var.domain_name}" : google_cloud_run_v2_service.default.uri
}

output "domain_name" {
  description = "The custom domain name for the application."
  value       = var.domain_name
}

output "service_name" {
  description = "The name of the Cloud Run service."
  value       = local.service_name
}

output "location" {
  description = "The GCP region where the service is deployed."
  value       = var.gcp_region
}

output "google_auth_client_id" {
  description = "The client ID for Google OAuth."
  value = google_identity_platform_default_supported_idp_config.google.client_id
  sensitive = true
}

output "google_auth_client_secret" {
  description = "The client secret for Google OAuth."
  value = google_identity_platform_default_supported_idp_config.google.client_secret
  sensitive = true
}

variable "image_tag" {
  description = "The tag to use for the container image."
  type        = string
  default     = "latest"
}

output "project_id" {
  description = "The ID of the GCP project."
  value       = var.project_id
}

output "repository_id" {
  description = "The ID of the Artifact Registry repository."
  value       = google_artifact_registry_repository.repository.repository_id
}
