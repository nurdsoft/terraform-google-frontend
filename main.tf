# Root module - orchestrates the frontend edge stack for a Cloud Run-backed web
# frontend on GCP. Composes six Terraform Registry sub-modules: Cloud Armor,
# external HTTPS LB, Artifact Registry, project logging (log bucket + sink),
# a log-sink service account, and Cloud Monitoring alert policies.

# Cloud Armor WAF policy - attached to the LB backend service via the
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

# Artifact Registry Docker repository for the frontend's container images.
# Unconditional - every frontend deploy needs somewhere to push its image.
module "artifact_registry" {
  source  = "nurdsoft/artifact-registry/google"
  version = "0.1.1"

  project_id    = var.project_id
  location      = var.region
  repository_id = var.artifact_registry_repo_id
  format        = "DOCKER"
}

# Log bucket + sink for LB request logs.
# enable_logging and enable_alerts require enable_ingress = true, since both
# reference module.external_https_lb[0].url_map_name.
module "log_stack" {
  count   = var.customer_domain != "" && var.enable_logging ? 1 : 0
  source  = "nurdsoft/project-logging/google"
  version = "1.0.1"

  project_id     = var.project_id
  bucket_id      = "${var.component}-${var.log_bucket_id_suffix}"
  location       = var.log_bucket_location
  retention_days = var.log_retention_days
  sink_name      = "${var.component}-lb-logs"
  sink_filter    = "resource.labels.url_map_name=\"${module.external_https_lb[0].url_map_name}\""
}

# Log-sink service account. Created unconditionally so the SA name stays
# stable across enable_logging toggles; roles are only granted when logging
# is actually on.
module "log_sink_sa" {
  source  = "nurdsoft/service-account/google"
  version = "1.0.1"

  project_id   = var.project_id
  account_id   = "${var.component}-${var.log_bucket_id_suffix}-sa"
  display_name = "Log sink service account for frontend logs"
  roles        = var.customer_domain != "" && var.enable_logging ? ["roles/logging.bucketWriter"] : []
}

# Cloud Monitoring alert policies for the frontend edge.
# enable_built_in_policies is hardcoded false: the sub-module's built-ins are
# Cloud Run + Cloud SQL policies which are irrelevant to a frontend LB stack.
# The two frontend-specific policies (http_5xx_error_rate, uptime_check_failures)
# live in locals.built_in_frontend_alert_policies and are merged in when
# enable_built_in_frontend_alert_policies is true.
module "alert_policies" {
  count   = var.customer_domain != "" && var.enable_alerts ? 1 : 0
  source  = "nurdsoft/alert-policies/google"
  version = "1.1.0"

  enable_built_in_policies = false
  notification_channels    = var.notification_channels
  additional_alert_policies = merge(
    var.enable_built_in_frontend_alert_policies ? local.built_in_frontend_alert_policies : {},
    var.additional_alert_policies,
  )
}
