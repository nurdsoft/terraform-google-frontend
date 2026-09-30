# Complete example - provisions the full frontend edge stack (LB + WAF +
# Artifact Registry + log stack + alert policies) in front of an existing
# Cloud Run service.

module "frontend" {
  source = "../.."

  # Identity
  project_id             = var.project_id
  region                 = var.region
  component              = var.component
  environment            = var.environment
  cloud_run_service_name = var.cloud_run_service_name

  # HTTPS
  customer_domain = var.customer_domain

  # Uptime check tuning
  uptime_check_path    = var.uptime_check_path
  uptime_check_period  = var.uptime_check_period
  uptime_check_timeout = var.uptime_check_timeout

  # Feature flags (all default to true; overrides shown for illustration)
  enable_ingress = var.enable_ingress
  enable_waf     = var.enable_waf
  enable_logging = var.enable_logging
  enable_alerts  = var.enable_alerts

  # Cloud Armor
  waf_description   = var.waf_description
  waf_allowed_paths = var.waf_allowed_paths

  # Artifact Registry
  artifact_registry_repo_id = var.artifact_registry_repo_id

  # Alert policies
  notification_channels = var.notification_channels
}
