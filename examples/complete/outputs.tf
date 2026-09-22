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
