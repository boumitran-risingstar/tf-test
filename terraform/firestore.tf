resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = var.firestore_database_name
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
  cmek_key_name = google_kms_crypto_key.firestore_cmek_key.id # Added CMEK key

  depends_on = [
    google_project_service.project,
    google_kms_crypto_key.firestore_cmek_key,
    google_project_iam_member.firestore_cmek_binding
  ]
}
