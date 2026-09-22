# Root module outputs — aggregate the load-bearing outputs from submodules
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
