# Complete example — provisions the full frontend edge stack (LB + WAF)
# in front of an existing Cloud Run service.

module "frontend" {
  source = "../.."

  # Identity
  project_id             = var.project_id
  region                 = var.region
  component              = var.component
  cloud_run_service_name = var.cloud_run_service_name

  # HTTPS
  customer_domain = var.customer_domain

  # Uptime check tuning
  uptime_check_path    = var.uptime_check_path
  uptime_check_period  = var.uptime_check_period
  uptime_check_timeout = var.uptime_check_timeout

  # Cloud Armor
  enable_waf        = var.enable_waf
  waf_description   = var.waf_description
  waf_allowed_paths = var.waf_allowed_paths
}
