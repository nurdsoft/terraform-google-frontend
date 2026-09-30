locals {
  # Built-in frontend alert policies. These are frontend-specific (they depend
  # on the LB's url_map_name and the customer domain) and are conceptually part
  # of the frontend edge stack. Toggled by var.enable_built_in_frontend_alert_policies.
  #
  # Anyone extending these should also add an entry to the "Outputs" table in
  # README.md so callers know the policy is available under alert_policy_ids.
  built_in_frontend_alert_policies = var.enable_ingress ? {
    http_5xx_error_rate = {
      display_name    = "${var.component}-http-5xx-error-rate"
      project         = var.project_id
      severity        = "WARNING"
      condition_name  = "HTTP 5xx Error Rate > 5% for 5 minutes"
      filter          = "metric.type=\"loadbalancing.googleapis.com/https/request_count\" AND resource.type=\"https_lb_rule\" AND resource.labels.url_map_name=\"${module.external_https_lb[0].url_map_name}\" AND metric.labels.response_code_class=\"500\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.05
      aligner         = "ALIGN_RATE"
      reducer         = "REDUCE_MEAN"
      group_by_fields = ["resource.labels.url_map_name"]
      trigger_count   = 1
      user_labels = {
        alert_type  = "http_5xx_errors"
        environment = var.environment
        component   = var.component
      }
      documentation = {
        content   = "**HTTP 5xx Error Rate Alert**\n\nHTTP 5xx Error Rate has exceeded 5% for 5 minutes. This indicates server-side errors that require immediate attention."
        mime_type = "text/markdown"
      }
    }
    uptime_check_failures = {
      display_name    = "${var.component}-uptime-check-failures"
      project         = var.project_id
      severity        = "CRITICAL"
      condition_name  = "HTTPS Uptime Check Failed"
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND resource.labels.host=\"${var.customer_domain}\""
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1.0
      aligner         = null
      reducer         = null
      group_by_fields = []
      trigger_count   = 1
      user_labels = {
        alert_type  = "uptime_check_failures"
        environment = var.environment
        component   = var.component
      }
      documentation = {
        content   = "**Domain Unreachable / TLS Expired Alert**\n\nUptime check has failed, indicating the domain is unreachable or there are SSL/TLS issues.\n\n**Possible Causes:**\n- Domain DNS issues\n- SSL certificate expired\n- Load balancer down\n- CDN configuration problems\n- Network connectivity issues\n\n**Action Required:**\n- Check domain DNS resolution\n- Verify SSL certificate validity\n- Check load balancer health\n- Review CDN configuration"
        mime_type = "text/markdown"
      }
    }
  } : {}
}
