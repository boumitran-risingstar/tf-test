####################################################################################
# Provider
####################################################################################

provider "google" {
  project = var.project_id
  region  = var.region
  user_project_override = true
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  user_project_override = true
}

####################################################################################
# APIs & Foundational IAM
####################################################################################

# Enable necessary APIs for the project
resource "google_project_service" "project" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com",
    "firebase.googleapis.com"
  ])
  service = each.key
}

# --- Service Account for Cloud Run ---
resource "google_service_account" "default" {
  account_id   = "auth-ui-sa"
  display_name = "Auth UI Service Account"
}

# --- Service Account for Users API ---
resource "google_service_account" "users_api" {
  account_id   = "users-api-sa"
  display_name = "Users API Service Account"
}

# --- Service Account for Cloud Build ---
resource "google_service_account" "cloudbuild" {
  account_id   = "cloud-build-sa"
  display_name = "Cloud Build Service Account"
}

# Grant the deployer user the ability to act as the Cloud Run service account
resource "google_service_account_iam_member" "service_account_user" {
  service_account_id = google_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.deploy_user_email}"
}

# Grant the deployer user the ability to act as the Users API service account
resource "google_service_account_iam_member" "users_api_service_account_user" {
  service_account_id = google_service_account.users_api.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.deploy_user_email}"
}

# Grant the new Cloud Build SA necessary permissions
resource "google_project_iam_member" "cloud_build_permissions" {
  for_each = toset([
    "roles/run.admin",
    "roles/artifactregistry.writer"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Grant the Cloud Build service account the ability to act as the Cloud Run service account
resource "google_service_account_iam_member" "cloudbuild_is_serviceAccountUser_for_cloudrun" {
  service_account_id = google_service_account.default.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Grant the Cloud Build service account the ability to act as the Users API service account
resource "google_service_account_iam_member" "cloudbuild_is_serviceAccountUser_for_users_api" {
  service_account_id = google_service_account.users_api.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.cloudbuild.email}"
}

####################################################################################
# Service Account Key & Secret Manager
####################################################################################

resource "google_service_account_key" "auth_ui_sa_key" {
  service_account_id = google_service_account.default.name
}

resource "google_secret_manager_secret" "firebase_service_account_key" {
  secret_id = "firebase-service-account-key"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "firebase_service_account_key_version" {
  secret      = google_secret_manager_secret.firebase_service_account_key.id
  secret_data = google_service_account_key.auth_ui_sa_key.private_key
}

resource "google_secret_manager_secret_iam_member" "firebase_sa_key_accessor" {
  secret_id = google_secret_manager_secret.firebase_service_account_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.default.email}"
}

resource "google_project_iam_member" "firebase_admin_role" {
  project = var.project_id
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${google_service_account.default.email}"
}


####################################################################################
# Artifact Registry & Build Log Bucket
####################################################################################

resource "google_artifact_registry_repository" "default" {
  location      = var.region
  repository_id = local.repository_id
  description   = "Docker repository for ${var.app_name}"
  format        = "DOCKER"
  depends_on = [
    google_project_service.project
  ]
}

# --- Cloud Build Log Bucket ---
resource "google_storage_bucket" "cloudbuild_logs" {
  name          = "${var.project_id}-cloudbuild-logs"
  location      = var.region
  force_destroy = true # Optional: Allows deletion of the bucket even if it contains objects
}

# Grant the Cloud Build service account permission to write to the log bucket
resource "google_storage_bucket_iam_member" "cloudbuild_log_writer" {
  bucket = google_storage_bucket.cloudbuild_logs.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# --- Cloud Build Source Bucket ---
resource "google_storage_bucket" "cloudbuild_source" {
  name          = "${var.project_id}-cloudbuild-source"
  location      = var.region
  force_destroy = true # Optional: Allows deletion of the bucket even if it contains objects
}

# Grant the Cloud Build service account permission to read and write to the source bucket
resource "google_storage_bucket_iam_member" "cloudbuild_source_admin" {
  bucket = google_storage_bucket.cloudbuild_source.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloudbuild.email}"
}


####################################################################################
# Cloud Run Service
####################################################################################

resource "google_cloud_run_v2_service" "default" {
  count    = var.deploy_cloud_run ? 1 : 0
  provider = google-beta
  name     = local.service_name
  location = var.region
  deletion_protection = false

  template {
    service_account = google_service_account.default.email
    containers {
      image = "us-central1-docker.pkg.dev/${var.project_id}/${local.repository_id}/${local.service_name}:latest"
      env {
        name  = "USERS_API_URL"
        value = google_cloud_run_v2_service.users_api[0].uri
      }
      env {
        name  = "DEPLOY_TIMESTAMP"
        value = var.deploy_timestamp
      }
      env {
        name  = "FIREBASE_SERVICE_ACCOUNT_KEY"
        value = google_secret_manager_secret_version.firebase_service_account_key_version.secret_data
      }
    }
    # Use a Serverless NEG for the load balancer integration or allow all traffic
    annotations = {
      "run.googleapis.com/ingress" = var.use_load_balancer ? "internal-and-cloud-load-balancing" : "all"
    }
  }
  depends_on = [
    google_project_service.project
  ]
}

# Allow unauthenticated access to the Cloud Run service if not using the load balancer
resource "google_cloud_run_service_iam_member" "noauth" {
  count    = var.deploy_cloud_run && !var.use_load_balancer ? 1 : 0
  location = google_cloud_run_v2_service.default[0].location
  project  = google_cloud_run_v2_service.default[0].project
  service  = google_cloud_run_v2_service.default[0].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# --- Domain Mapping ---
resource "google_cloud_run_domain_mapping" "default" {
  count    = var.deploy_cloud_run && !var.use_load_balancer && var.domain_name != "" ? 1 : 0
  location = var.region
  name     = var.domain_name
  metadata {
    namespace = var.project_id
  }
  spec {
    route_name = google_cloud_run_v2_service.default[0].name
  }
}

resource "google_cloud_run_v2_service" "users_api" {
  count    = var.deploy_cloud_run ? 1 : 0
  provider = google-beta
  name     = var.users_api_service_name
  location = var.region
  deletion_protection = false

  template {
    service_account = google_service_account.users_api.email
    containers {
      image = "us-central1-docker.pkg.dev/${var.project_id}/${local.repository_id}/${var.users_api_service_name}:latest"
      env {
        name  = "DEPLOY_TIMESTAMP"
        value = var.deploy_timestamp
      }
    }
    # Use a Serverless NEG for the load balancer integration or allow all traffic
    annotations = {
      "run.googleapis.com/ingress" = "internal"
    }
  }
  depends_on = [
    google_project_service.project
  ]
}

# Allow authenticated access to the Cloud Run service
resource "google_cloud_run_service_iam_member" "users_api_auth" {
  count    = var.deploy_cloud_run ? 1 : 0
  location = google_cloud_run_v2_service.users_api[0].location
  project  = google_cloud_run_v2_service.users_api[0].project
  service  = google_cloud_run_v2_service.users_api[0].name
  role     = "roles/run.invoker"
  member   = "user:${var.deploy_user_email}"
}

# Allow auth-ui to invoke users-api
resource "google_cloud_run_service_iam_member" "auth_ui_invokes_users_api" {
  count    = var.deploy_cloud_run ? 1 : 0
  location = google_cloud_run_v2_service.users_api[0].location
  project  = google_cloud_run_v2_service.users_api[0].project
  service  = google_cloud_run_v2_service.users_api[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.default.email}"
}


####################################################################################
# Global External Load Balancer
####################################################################################

# --- Backend Service & NEG ---
resource "google_compute_region_network_endpoint_group" "neg" {
  count                 = var.deploy_cloud_run && var.use_load_balancer ? 1 : 0
  provider              = google-beta
  name                  = local.neg_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_v2_service.default[0].name
  }
}

resource "google_compute_backend_service" "default" {
  count                 = var.deploy_cloud_run && var.use_load_balancer ? 1 : 0
  name                  = local.backend_service_name
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.neg[0].id
  }
}

# --- Frontend (IP, SSL, Routing) ---
resource "google_compute_global_address" "default" {
  count = var.use_load_balancer ? 1 : 0
  name  = local.static_ip_name
}

resource "google_compute_managed_ssl_certificate" "default" {
  count   = var.use_load_balancer ? 1 : 0
  name    = local.ssl_certificate_name
  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_url_map" "default" {
  count           = var.use_load_balancer ? 1 : 0
  name            = local.url_map_name
  default_service = google_compute_backend_service.default[0].id
}

resource "google_compute_target_https_proxy" "default" {
  count            = var.use_load_balancer ? 1 : 0
  name             = local.https_proxy_name
  url_map          = google_compute_url_map.default[0].id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

resource "google_compute_global_forwarding_rule" "default" {
  count                 = var.use_load_balancer ? 1 : 0
  name                  = local.https_forwarding_rule_name
  ip_protocol           = "TCP"
  port_range            = "443"
  ip_address            = google_compute_global_address.default[0].address
  target                = google_compute_target_https_proxy.default[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# --- HTTP-to-HTTPS Redirect ---

resource "google_compute_url_map" "redirect" {
  count = var.use_load_balancer ? 1 : 0
  name  = "${local.url_map_name}-redirect"
  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
  }
}

resource "google_compute_target_http_proxy" "default" {
  count   = var.use_load_balancer ? 1 : 0
  name    = local.http_proxy_name
  url_map = google_compute_url_map.redirect[0].id
}

resource "google_compute_global_forwarding_rule" "http" {
  count                 = var.use_load_balancer ? 1 : 0
  name                  = local.http_forwarding_rule_name
  ip_protocol           = "TCP"
  port_range            = "80"
  ip_address            = google_compute_global_address.default[0].address
  target                = google_compute_target_http_proxy.default[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

####################################################################################
# IAP (Identity-Aware Proxy)
####################################################################################

# Note: IAP requires an OAuth consent screen to be configured for the project.
# This resource binds the IAP role to the backend service.
resource "google_iap_web_backend_service_iam_member" "default" {
  count                = var.use_load_balancer ? 1 : 0
  project              = var.project_id
  web_backend_service  = google_compute_backend_service.default[0].name
  role                 = "roles/iap.httpsIapUser"
  member               = "user:${var.deploy_user_email}" # Example: grant access to the deployer
}
