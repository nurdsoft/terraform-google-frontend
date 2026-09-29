output "static_ip_address" {
  description = "Reserved external IPv4 in front of the LB."
  value       = module.frontend.static_ip_address
}

output "url_map_name" {
  description = "Main URL map name."
  value       = module.frontend.url_map_name
}

output "dashboard_id" {
  description = "Monitoring dashboard ID."
  value       = module.frontend.dashboard_id
}

output "armor_policy_self_link" {
  description = "Cloud Armor policy self link. Null when enable_waf is false."
  value       = module.frontend.armor_policy_self_link
}

output "artifact_registry_repository_url" {
  description = "Pull URL for the Artifact Registry repository."
  value       = module.frontend.artifact_registry_repository_url
}

output "log_bucket_id" {
  description = "Short ID of the log bucket. Null when logging is disabled."
  value       = module.frontend.log_bucket_id
}

output "log_sink_service_account_email" {
  description = "Email of the log-sink service account."
  value       = module.frontend.log_sink_service_account_email
}

output "alert_policy_names" {
  description = "Map of alert-policy keys to GCP resource names."
  value       = module.frontend.alert_policy_names
}
