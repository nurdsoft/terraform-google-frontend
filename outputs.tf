# Root module outputs - aggregate the load-bearing outputs from submodules
# so callers wire log sinks and alert policies without reaching into the
# wrapper's internal module addresses.

# ------------------------------------------------------------------------------
# External HTTPS load balancer
# ------------------------------------------------------------------------------

output "static_ip_address" {
  description = "Reserved external IPv4 address in front of the load balancer. Point the customer domain's A record here. Null when enable_ingress is false."
  value       = var.enable_ingress ? module.external_https_lb[0].static_ip_address : null
}

output "url_map_name" {
  description = "Name of the main URL map. Use this in log sink filters (`resource.labels.url_map_name`) and alert-policy metric filters. Null when enable_ingress is false."
  value       = var.enable_ingress ? module.external_https_lb[0].url_map_name : null
}

output "dashboard_id" {
  description = "ID of the monitoring dashboard. Null when enable_ingress is false, the dashboard is disabled, or customer_domain is empty."
  value       = var.enable_ingress ? module.external_https_lb[0].dashboard_id : null
}

# ------------------------------------------------------------------------------
# Cloud Armor
# ------------------------------------------------------------------------------

output "armor_policy_self_link" {
  description = "Self link of the Cloud Armor policy. Null when enable_waf is false."
  value       = var.enable_waf ? module.cloud_armor[0].self_link : null
}

# ------------------------------------------------------------------------------
# Artifact Registry
# ------------------------------------------------------------------------------

output "artifact_registry_repository_id" {
  description = "Repository ID of the frontend Artifact Registry repository."
  value       = module.artifact_registry.repository_id
}

output "artifact_registry_repository_url" {
  description = "Pull URL for the Artifact Registry repository (e.g. us-central1-docker.pkg.dev/<project>/<repo>)."
  value       = module.artifact_registry.repository_url
}

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

output "log_bucket_id" {
  description = "Short ID of the log bucket (<component>-<log_bucket_id_suffix>). Null when logging is disabled."
  value       = length(module.log_stack) > 0 ? "${var.component}-${var.log_bucket_id_suffix}" : null

  precondition {
    condition     = !(var.enable_logging && !var.enable_ingress)
    error_message = "enable_logging requires enable_ingress = true (the log-sink filter references module.external_https_lb[0].url_map_name)."
  }
}

output "log_bucket_resource_name" {
  description = "Full resource name of the log bucket (projects/{project}/locations/{location}/buckets/{bucket_id}). Null when logging is disabled."
  value       = length(module.log_stack) > 0 ? module.log_stack[0].bucket_resource_name : null
}

output "log_sink_writer_identity" {
  description = "Writer identity of the LB log sink. Grant this identity write access to any destination bucket. Null when logging is disabled."
  value       = length(module.log_stack) > 0 ? module.log_stack[0].sink_writer_identity : null
}

output "log_sink_service_account_email" {
  description = "Email of the pre-provisioned log-sink service account. Grants roles/logging.bucketWriter only when logging is on."
  value       = module.log_sink_sa.service_account_email
}

# ------------------------------------------------------------------------------
# Alert policies
# ------------------------------------------------------------------------------

output "alert_policy_ids" {
  description = "Map of alert-policy keys to their GCP resource IDs (built-in frontend policies + any additional). Empty map when alerts are disabled."
  value       = length(module.alert_policies) > 0 ? module.alert_policies[0].additional_alert_policy_ids : {}

  precondition {
    condition     = !(var.enable_alerts && !var.enable_ingress)
    error_message = "enable_alerts requires enable_ingress = true (built-in alert policies reference module.external_https_lb[0].url_map_name)."
  }
}

output "alert_policy_names" {
  description = "Map of alert-policy keys to their GCP resource names. Empty map when alerts are disabled."
  value       = length(module.alert_policies) > 0 ? module.alert_policies[0].additional_alert_policy_names : {}
}
