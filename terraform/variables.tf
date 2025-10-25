####################################################################################
# Variables
####################################################################################

variable "project_id" {
  description = "The project ID to deploy to."
  type        = string
}

variable "region" {
  description = "The region to deploy to."
  type        = string
}

variable "app_name" {
  description = "The overall name of the application."
  type        = string
  default     = "mouth-metrics"
}

variable "service_name" {
  description = "The name of the specific service being deployed."
  type        = string
  default     = "auth-ui"
}

variable "deploy_user_email" {
  description = "The email of the user deploying the infrastructure."
  type        = string
}

variable "use_load_balancer" {
  description = "If true, create a global external load balancer."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "The domain name for the application."
  type        = string
  default     = ""
}
