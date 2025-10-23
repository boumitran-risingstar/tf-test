
variable "use_load_balancer" {
  description = "If true, a global HTTPS load balancer, WAF, and CDN will be configured. If false, Cloud Run's native domain mapping will be used instead."
  type        = bool
  default     = false
}
