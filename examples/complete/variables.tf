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

variable "enable_waf" {
  description = "Enable Cloud Armor WAF policy."
  type        = bool
  default     = false
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
