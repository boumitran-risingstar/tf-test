output "project_id" {
  value = var.project_id
}

output "location" {
  value = var.region
}

output "repository_id" {
  value = local.repository_id
}

output "service_name" {
  value = local.service_name
}

output "app_url" {
  description = "The URL of the deployed application"
  value       = var.use_load_balancer ? "https://${var.domain_name}" : google_cloud_run_v2_service.default.uri
}

output "service_url" {
  description = "The direct URL to the Cloud Run service"
  value       = google_cloud_run_v2_service.default.uri
}

output "cloud_build_service_account_email" {
  description = "The email of the service account used by Cloud Build."
  value       = google_service_account.cloudbuild.email
}

output "cloud_build_service_account_name" {
  description = "The full name of the service account used by Cloud Build."
  value       = google_service_account.cloudbuild.name
}


output "use_load_balancer" {
  description = "Indicates whether a load balancer is used."
  value       = var.use_load_balancer
}

output "lb_ip_address" {
  description = "The IP address of the load balancer."
  value       = var.use_load_balancer ? google_compute_global_address.default[0].address : "N/A"
}

output "domain_name" {
  description = "The domain name for the application."
  value       = var.domain_name
}
