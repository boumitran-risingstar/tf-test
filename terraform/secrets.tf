# Enable the Secret Manager API
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Get a reference to the existing client ID secret
data "google_secret_manager_secret" "google_auth_client_id" {
  project   = var.project_id
  secret_id = "auth-ui-google-auth-client-id"
}

# Get a reference to the existing client secret secret
data "google_secret_manager_secret" "google_auth_client_secret" {
  project   = var.project_id
  secret_id = "auth-ui-google-auth-client-secret"
}

# Grant the Cloud Build service account access to the client ID secret
resource "google_secret_manager_secret_iam_member" "google_auth_client_id_accessor_cloudbuild" {
  project   = data.google_secret_manager_secret.google_auth_client_id.project
  secret_id = data.google_secret_manager_secret.google_auth_client_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Grant the Cloud Build service account access to the client secret secret
resource "google_secret_manager_secret_iam_member" "google_auth_client_secret_accessor_cloudbuild" {
  project   = data.google_secret_manager_secret.google_auth_client_secret.project
  secret_id = data.google_secret_manager_secret.google_auth_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudbuild.email}"
}

# Grant the Cloud Run service account access to the client ID secret
resource "google_secret_manager_secret_iam_member" "google_auth_client_id_accessor_cloudrun" {
  project   = data.google_secret_manager_secret.google_auth_client_id.project
  secret_id = data.google_secret_manager_secret.google_auth_client_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.default.email}"
}

# Grant the Cloud Run service account access to the client secret secret
resource "google_secret_manager_secret_iam_member" "google_auth_client_secret_accessor_cloudrun" {
  project   = data.google_secret_manager_secret.google_auth_client_secret.project
  secret_id = data.google_secret_manager_secret.google_auth_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.default.email}"
}
