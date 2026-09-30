variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "component" {
  description = "Prefix for created resources."
  type        = string
  default     = "frontend"
}

variable "environment" {
  description = "Environment label (dev/prod). Stamped on alert-policy user_labels."
  type        = string
  default     = "dev"
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run service the LB routes to."
  type        = string
}

variable "customer_domain" {
  description = "Customer domain name. Leave blank to skip HTTPS setup."
  type        = string
  default     = ""
}

variable "uptime_check_path" {
  description = "Path for the HTTPS uptime check."
  type        = string
  default     = "/"
}

variable "uptime_check_period" {
  description = "Frequency of uptime checks in seconds."
  type        = number
  default     = 300
}

variable "uptime_check_timeout" {
  description = "Timeout for uptime checks in seconds."
  type        = number
  default     = 10
}

variable "enable_ingress" {
  description = "Enable the external HTTPS load balancer."
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable Cloud Armor WAF policy."
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Create a log bucket and route LB request logs to it."
  type        = bool
  default     = true
}

variable "enable_alerts" {
  description = "Create Cloud Monitoring alert policies for the frontend edge."
  type        = bool
  default     = true
}

variable "waf_description" {
  description = "Description on the Cloud Armor policy."
  type        = string
  default     = "Frontend WAF - Cloud Armor policy"
}

variable "waf_allowed_paths" {
  description = "Paths that bypass WAF block rules."
  type        = list(string)
  default     = []
}

variable "artifact_registry_repo_id" {
  description = "Repository ID for the frontend's Artifact Registry Docker repository."
  type        = string
}

variable "notification_channels" {
  description = "List of Cloud Monitoring notification channel IDs to attach to alert policies."
  type        = list(string)
  default     = []
}
