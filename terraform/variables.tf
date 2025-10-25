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
