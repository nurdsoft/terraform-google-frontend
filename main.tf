# Root module - orchestrates the frontend edge stack (Cloud Armor + External HTTPS LB)
# using Terraform Registry modules.

# Cloud Armor WAF policy — attached to the LB backend service via the
# external_https_lb module below when var.enable_waf is true.
module "cloud_armor" {
  count         = var.enable_waf ? 1 : 0
  source        = "nurdsoft/cloud-armor/google"
  version       = "1.0.0"
  project_id    = var.project_id
  name          = "${var.component}-armor-policy"
  description   = var.waf_description
  allowed_paths = var.waf_allowed_paths
}

# External HTTPS load balancer for the Cloud Run frontend service.
# Provisions: static IP, Serverless NEG, backend service, main URL map,
# HTTP->HTTPS redirect, managed SSL cert, HTTPS forwarding rule, uptime
# checks, monitoring dashboard.
module "external_https_lb" {
  count   = var.enable_ingress ? 1 : 0
  source  = "nurdsoft/lb/google"
  version = "1.0.0"

  project_id             = var.project_id
  component              = var.component
  region                 = var.region
  cloud_run_service_name = var.cloud_run_service_name

  customer_domain      = var.customer_domain
  uptime_check_path    = var.uptime_check_path
  uptime_check_period  = var.uptime_check_period
  uptime_check_timeout = var.uptime_check_timeout

  # Attach WAF only when enabled; backend log_config is auto-enabled inside
  # the module when a security policy is attached.
  security_policy_self_link = var.enable_waf ? module.cloud_armor[0].self_link : null
}
