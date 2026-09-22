project_id             = "your-gcp-project-id"
region                 = "us-central1"
component              = "frontend"
cloud_run_service_name = "your-cloud-run-service"

customer_domain = "app.example.com"

uptime_check_path    = "/"
uptime_check_period  = 300
uptime_check_timeout = 10

enable_waf      = true
waf_description = "Frontend WAF - Cloud Armor policy"
waf_allowed_paths = [
  "/robots.txt",
  "/sitemap*",
]
