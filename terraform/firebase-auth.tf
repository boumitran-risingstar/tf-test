resource "google_project_service" "identitytoolkit" {
  service = "identitytoolkit.googleapis.com"
}

resource "google_identity_platform_config" "default" {
  project = var.project_id
  autodelete_anonymous_users = true

  sign_in {
    allow_duplicate_emails = false
    email {
      enabled = true
      password_required = true
    }
  }

  depends_on = [google_project_service.identitytoolkit]
}

resource "google_identity_platform_default_supported_idp_config" "google" {
  project   = var.project_id
  idp_id    = "google.com"
  client_id = google_iap_client.project_client.client_id
  client_secret = google_iap_client.project_client.secret
  enabled   = true

  depends_on = [google_identity_platform_config.default]
}

resource "google_project_service" "firebase" {
  service = "firebase.googleapis.com"
}

resource "google_project_iam_member" "firebase_auth_viewer" {
  project = var.project_id
  role    = "roles/firebaseauth.viewer"
  member  = "user:${var.deploy_user_email}"
}
