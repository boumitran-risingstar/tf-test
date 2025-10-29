resource "google_firestore_database" "database" {
  count       = var.firestore_database_name != "" ? 1 : 0
  project     = var.project_id
  name        = var.firestore_database_name
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  dynamic "cmek_config" {
    for_each = var.kms_project_id != "" ? [1] : []
    content {
      kms_key_name = google_kms_crypto_key.firestore_cmek_key[0].id
    }
  }

  depends_on = [
    google_project_service.project,
    google_kms_crypto_key.firestore_cmek_key,
    #google_kms_crypto_key_iam_member.firestore_cmek_binding
  ]

  lifecycle {
    ignore_changes = all
  }
}
