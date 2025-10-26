variable "deploy_cloud_run" {
  description = "A boolean flag to control the creation of the Cloud Run service."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "deploy_user_email" {
  description = "The email address of the user deploying the application."
  type        = string
}

variable "region" {
  description = "The Google Cloud region for the resources"
  type        = string
}

variable "use_load_balancer" {
  description = "A boolean flag to control the creation of the Load Balancer."
  type = bool
  default = false
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
}

variable "domain_name" {
  description = "The domain name for the application."
  type        = string
}
