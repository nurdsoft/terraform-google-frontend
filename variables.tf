# -----------------------------------------------------------------------------
# Identity
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID that owns the frontend edge resources."
  type        = string
}

variable "region" {
  description = "GCP region for regional resources (Cloud Run backend, Artifact Registry, etc.)."
  type        = string
  default     = "us-central1"
}

variable "component" {
  description = "Short name used as a prefix for created resources. The Cloud Armor policy is named <component>-armor-policy."
  type        = string
  default     = "frontend"
}

variable "environment" {
  description = "Environment label (e.g. dev, prod). Stamped on alert-policy user_labels so notifications indicate the source env."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# External HTTPS load balancer
# -----------------------------------------------------------------------------

variable "customer_domain" {
  description = "Customer domain name. Leave blank to skip HTTPS setup and to disable the log_stack + alert_policies sub-modules. e.g. app.example.com"
  type        = string
  default     = ""
}

variable "cloud_run_service_name" {
  description = "Name of the Cloud Run service the LB routes traffic to via a Serverless NEG."
  type        = string
}

variable "enable_ingress" {
  description = "Enable the external HTTPS load balancer (the ingress edge). Default true - the LB is the primary reason this module exists. Set false only if you want a Cloud Armor policy without an LB attached (rare). Note: enable_logging and enable_alerts both require this to be true, since they reference the LB's url_map_name."
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

# -----------------------------------------------------------------------------
# Artifact Registry
# -----------------------------------------------------------------------------

variable "artifact_registry_repo_id" {
  description = "Repository ID for the Artifact Registry Docker repository that stores the frontend's container images."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Project logging (log bucket + sink)
# -----------------------------------------------------------------------------

variable "enable_logging" {
  description = "Create a project-scoped log bucket and route the LB's request logs to it via a log sink. Requires enable_ingress = true (sink filter references the LB's url_map_name) and a non-empty customer_domain. Default true."
  type        = bool
  default     = true
}

variable "log_bucket_id_suffix" {
  description = "Suffix appended to <component> to form the log bucket ID and the log-sink SA name."
  type        = string
  default     = "logs"
}

variable "log_bucket_location" {
  description = "Location for the log bucket."
  type        = string
  default     = "global"
}

variable "log_retention_days" {
  description = "Retention period for the log bucket, in days."
  type        = number
  default     = 30
}

# -----------------------------------------------------------------------------
# Alert policies
# -----------------------------------------------------------------------------

variable "enable_alerts" {
  description = "Create Cloud Monitoring alert policies for the frontend edge. Requires enable_ingress = true (built-in policies reference the LB's url_map_name) and a non-empty customer_domain. Default true."
  type        = bool
  default     = true
}

variable "enable_built_in_frontend_alert_policies" {
  description = "Enable the two built-in frontend policies: http_5xx_error_rate and uptime_check_failures. Both reference the LB's url_map_name and the customer_domain. Default true. Set false if you want to supply your own policies via additional_alert_policies only. Not to be confused with nurdsoft/alert-policies/google's own enable_built_in_policies (Cloud Run + Cloud SQL policies), which the wrapper hardcodes to false - a frontend edge stack never needs those."
  type        = bool
  default     = true
}

variable "notification_channels" {
  description = "List of existing Cloud Monitoring notification channel IDs to attach to every alert policy created by this wrapper."
  type        = list(string)
  default     = []
}

variable "additional_alert_policies" {
  description = "Extra alert-policy definitions merged on top of the built-in frontend policies. Same shape as nurdsoft/alert-policies/google's additional_alert_policies input."
  type        = any
  default     = {}
}
