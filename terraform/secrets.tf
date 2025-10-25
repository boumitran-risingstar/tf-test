# Enable the Secret Manager API
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
}

# Get a reference to the existing client ID secret
data "google_secret_manager_secret" "google_auth_client_id" {
  secret_id = "${var.app_name}-google-auth-client-id"
}

# Get a reference to the existing client secret secret
data "google_secret_manager_secret" "google_auth_client_secret" {
  secret_id = "${var.app_name}-google-auth-client-secret"
}

# Grant the deployer service account access to the client ID secret
resource "google_secret_manager_secret_iam_member" "google_auth_client_id_accessor" {
  project   = data.google_secret_manager_secret.google_auth_client_id.project
  secret_id = data.google_secret_manager_secret.google_auth_client_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}

# Grant the deployer service account access to the client secret secret
resource "google_secret_manager_secret_iam_member" "google_auth_client_secret_accessor" {
  project   = data.google_secret_manager_secret.google_auth_client_secret.project
  secret_id = data.google_secret_manager_secret.google_auth_client_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com"
}
