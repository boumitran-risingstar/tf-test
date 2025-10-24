
variable "app_name" {
  description = "The name of the application. Used as a prefix for many resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.app_name))
    error_message = "The app_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string

  validation {
    condition     = var.project_id != "your-gcp-project-id" && var.project_id != ""
    error_message = "A valid project_id must be provided. Please create a terraform.tfvars file and set your project_id. See terraform.tfvars.example for a template."
  }
}

variable "use_load_balancer" {
  description = "If true, a global HTTPS load balancer, WAF, and CDN will be configured. If false, Cloud Run's native domain mapping will be used instead."
  type        = bool
  default     = false
}

variable "gcp_region" {
  description = "The Google Cloud region to deploy resources to."
  type        = string
  default     = "us-central1"
}

variable "domain_name" {
  description = "The domain name for the Cloud Run service."
  type        = string
  default     = "mouthmetrics.32studio.org"
}

variable "deploy_user_email" {
  description = "The email of the user running the deployment. This user will be granted the Cloud Build Editor role."
  type        = string
}
