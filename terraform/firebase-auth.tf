# Enable the Identity Toolkit API
resource "google_project_service" "identitytoolkit" {
  service = "identitytoolkit.googleapis.com"
}

# Basic Identity Platform configuration
resource "google_identity_platform_config" "default" {
  project                    = var.project_id
  autodelete_anonymous_users = true

  sign_in {
    allow_duplicate_emails = false
    email {
      enabled           = true
      password_required = true
    }
  }

  depends_on = [google_project_service.identitytoolkit]
}

# Get the latest version of the client ID secret
data "google_secret_manager_secret_version" "google_auth_client_id" {
  project = data.google_secret_manager_secret.google_auth_client_id.project
  secret  = data.google_secret_manager_secret.google_auth_client_id.secret_id
}

# Get the latest version of the client secret secret
data "google_secret_manager_secret_version" "google_auth_client_secret" {
  project = data.google_secret_manager_secret.google_auth_client_secret.project
  secret  = data.google_secret_manager_secret.google_auth_client_secret.secret_id
}

# Correctly configure Google as a sign-in provider.
resource "google_identity_platform_default_supported_idp_config" "google" {
  project       = var.project_id
  idp_id        = "google.com"
  enabled       = true
  client_id     = data.google_secret_manager_secret_version.google_auth_client_id.secret_data
  client_secret = data.google_secret_manager_secret_version.google_auth_client_secret.secret_data

  depends_on = [google_identity_platform_config.default]
}

# Enable the Firebase API
resource "google_project_service" "firebase" {
  service = "firebase.googleapis.com"
}

# Grant the deployer user the ability to view Firebase Auth resources.
resource "google_project_iam_member" "firebase_auth_viewer" {
  project = var.project_id
  role    = "roles/firebaseauth.viewer"
  member  = "user:${var.deploy_user_email}"
}
