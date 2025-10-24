
variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
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

variable "repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
  default     = "hello-world-repo"
}

variable "image_name" {
  description = "The name of the Docker image."
  type        = string
  default     = "hello-world-image"
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
  default     = "hello-world-service"
}

variable "neg_name" {
  description = "The name of the serverless network endpoint group."
  type        = string
  default     = "hello-world-neg"
}

variable "policy_name" {
  description = "The name of the security policy."
  type        = string
  default     = "hello-world-policy"
}

variable "backend_service_name" {
  description = "The name of the backend service."
  type        = string
  default     = "hello-world-backend-service"
}

variable "url_map_name" {
  description = "The name of the URL map."
  type        = string
  default     = "hello-world-url-map"
}

variable "static_ip_name" {
  description = "The name of the static IP address."
  type        = string
  default     = "hello-world-static-ip"
}

variable "ssl_certificate_name" {
  description = "The name of the SSL certificate."
  type        = string
  default     = "hello-world-ssl-cert"
}

variable "https_proxy_name" {
  description = "The name of the HTTPS proxy."
  type        = string
  default     = "hello-world-https-proxy"
}

variable "https_forwarding_rule_name" {
  description = "The name of the HTTPS forwarding rule."
  type        = string
  default     = "hello-world-https-forwarding-rule"
}

variable "http_proxy_name" {
  description = "The name of the HTTP proxy."
  type        = string
  default     = "hello-world-http-proxy"
}

variable "http_forwarding_rule_name" {
  description = "The name of the HTTP forwarding rule."
  type        = string
  default     = "hello-world-http-forwarding-rule"
}

variable "domain_name" {
  description = "The domain name for the Cloud Run service."
  type        = string
  default     = "mouthmetrics.32studio.org"
}
