# -----------------------------------------------------------------------------
# Identity
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID that owns the frontend edge resources."
  type        = string
}

variable "region" {
  description = "GCP region for regional resources (Cloud Run backend, etc.)."
  type        = string
  default     = "us-central1"
}

variable "component" {
  description = "Short name used as a prefix for created resources. The Cloud Armor policy is named <component>-armor-policy."
  type        = string
  default     = "frontend"
}

# -----------------------------------------------------------------------------
# External HTTPS load balancer
# -----------------------------------------------------------------------------

variable "customer_domain" {
  description = "Customer domain name. Leave blank to skip HTTPS setup. e.g. dev.agoapp.net"
  type        = string
  default     = ""
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run service the LB routes traffic to via a Serverless NEG."
  type        = string
}

variable "enable_ingress" {
  description = "Enable the external HTTPS load balancer (the ingress edge). Default true — the LB is the primary reason this module exists. Set false only if you want a Cloud Armor policy without an LB attached (rare)."
  type        = bool
  default     = true
}

variable "uptime_check_path" {
  description = "Path used by the HTTPS uptime check."
  type        = string
  default     = "/"
}

variable "uptime_check_period" {
  description = "Frequency of uptime checks, in seconds."
  type        = number
  default     = 300
}

variable "uptime_check_timeout" {
  description = "Timeout for uptime checks, in seconds."
  type        = number
  default     = 10
}

# -----------------------------------------------------------------------------
# Cloud Armor WAF
# -----------------------------------------------------------------------------

variable "enable_waf" {
  description = "Enable Cloud Armor WAF policy and attach it to the LB backend service."
  type        = bool
  default     = true
}

variable "waf_description" {
  description = "Human-readable description written on the Cloud Armor policy."
  type        = string
  default     = "Frontend WAF - Cloud Armor policy"
}

variable "waf_allowed_paths" {
  description = "Request paths that bypass all WAF block rules. Entries ending in \"*\" use prefix matching; all others use exact match. Passed to module.cloud_armor.allowed_paths."
  type        = list(string)
  default     = []
}
