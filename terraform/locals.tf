locals {
  # --- Shared Application Resources ---

  # The ID for the shared Artifact Registry repository.
  repository_id = "${var.app_name}-docker-repo"

  # The name for the URL map, which routes traffic to different services.
  url_map_name = "${var.app_name}-url-map"

  # The name for the static IP address for the load balancer.
  static_ip_name = "${var.app_name}-static-ip"

  # The name for the SSL certificate for the load balancer.
  ssl_certificate_name = "${var.app_name}-ssl-cert"

  # The name for the HTTPS proxy for the load balancer.
  https_proxy_name = "${var.app_name}-https-proxy"

  # The name for the HTTPS forwarding rule for the load balancer.
  https_forwarding_rule_name = "${var.app_name}-https-forwarding-rule"

  # The name for the HTTP proxy for the load balancer (for redirects).
  http_proxy_name = "${var.app_name}-http-proxy"

  # The name for the HTTP forwarding rule for the load balancer.
  http_forwarding_rule_name = "${var.app_name}-http-forwarding-rule"

  # --- Service-Specific Resources ---

  # The name of the Docker image for the service.
  image_name = "${var.service_name}-image"

  # The name of the Cloud Run service.
  service_name = var.service_name

  # The name of the Network Endpoint Group (NEG) for the service.
  neg_name = "${var.service_name}-neg"

  # The name of the IAP policy for the service.
  policy_name = "${var.service_name}-policy"

  # The name of the backend service for the load balancer.
  backend_service_name = "${var.service_name}-backend-service"
}
