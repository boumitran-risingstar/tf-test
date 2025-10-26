resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = var.firestore_database_name
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [
    google_project_service.project
  ]
}
