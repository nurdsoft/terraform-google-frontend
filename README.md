# GCP Frontend Template

A Terraform orchestrator module that provisions the ingress edge stack for a
Cloud Run–backed web frontend on GCP by composing official Terraform Registry
modules for Cloud Armor and the external HTTPS load balancer.

## Features

- Orchestrates 2 Terraform Registry modules (v1.0.0) for a complete frontend
  edge setup:
  - `nurdsoft/lb/google` — static IP, Serverless NEG, backend service, URL
    map, HTTP→HTTPS redirect, managed SSL cert, uptime checks, monitoring
    dashboard.
  - `nurdsoft/cloud-armor/google` — WAF policy attached to the LB backend
    service.
- Feature flags (`enable_ingress`, `enable_waf`) to toggle each submodule
  independently. `enable_ingress` defaults to true — the LB is the primary
  reason this module exists.
- Automatic wiring between submodules — when `enable_waf = true`, the Cloud
  Armor policy is attached to the LB backend service automatically.
- Re-exports the LB and Cloud Armor outputs that callers typically wire into
  log sinks and alert policies (`url_map_name`, `static_ip_address`,
  `dashboard_id`, `armor_policy_self_link`).

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                GCP Frontend Edge Template                    │
│                     (Orchestrator)                           │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│   ┌──────────────────┐         ┌──────────────────┐          │
│   │  Cloud Armor     │────────▶│  External HTTPS  │          │
│   │  WAF Policy      │ attach  │  Load Balancer   │          │
│   │  v1.0.0 (opt)    │         │  v1.0.0          │          │
│   └──────────────────┘         └──────────────────┘          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Usage

Consume via git-ref (matches the `terraform-google-monitoring` house style):

```hcl
module "frontend" {
  source = "git::https://github.com/nurdsoft/terraform-google-frontend.git?ref=v1.0.0"

  project_id             = "my-project"
  region                 = "us-central1"
  component              = "frontend"
  cloud_run_service_name = "my-frontend"
  customer_domain        = "app.example.com"

  # Feature flags (defaults shown)
  enable_ingress = true

  # Cloud Armor
  enable_waf        = true
  waf_description   = "Frontend WAF - Cloud Armor policy"
  waf_allowed_paths = ["/robots.txt", "/sitemap*"]

  # Uptime check tuning (optional; defaults shown)
  uptime_check_path    = "/"
  uptime_check_period  = 300
  uptime_check_timeout = 10
}
```

See [`examples/complete`](./examples/complete) for a full working example.

---

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3   |
| google    | >= 5.0   |

## Modules

| Name                | Source                          | Version |
|---------------------|---------------------------------|---------|
| cloud_armor         | nurdsoft/cloud-armor/google     | 1.0.0   |
| external_https_lb   | nurdsoft/lb/google              | 1.0.0   |

## Inputs

| Name                     | Description                                                                | Type           | Default                             | Required |
|--------------------------|----------------------------------------------------------------------------|----------------|-------------------------------------|----------|
| project_id               | GCP project ID.                                                            | `string`       | n/a                                 | yes      |
| region                   | GCP region.                                                                | `string`       | `us-central1`                       | no       |
| component                | Prefix for created resources.                                              | `string`       | `frontend`                          | no       |
| customer_domain          | Customer domain name. Blank skips HTTPS setup.                             | `string`       | `""`                                | no       |
| cloud_run_service_name   | Name of the Cloud Run service the LB routes to.                            | `string`       | n/a                                 | yes      |
| uptime_check_path        | Path for the HTTPS uptime check.                                           | `string`       | `/`                                 | no       |
| uptime_check_period      | Frequency of uptime checks in seconds.                                     | `number`       | `300`                               | no       |
| uptime_check_timeout     | Timeout for uptime checks in seconds.                                      | `number`       | `10`                                | no       |
| enable_ingress           | Enable the external HTTPS load balancer.                                   | `bool`         | `true`                              | no       |
| enable_waf               | Enable Cloud Armor WAF policy and attach to LB.                            | `bool`         | `true`                              | no       |
| waf_description          | Description on the Cloud Armor policy.                                     | `string`       | `Frontend WAF - Cloud Armor policy` | no       |
| waf_allowed_paths        | Paths that bypass WAF block rules. `*` suffix = prefix match.              | `list(string)` | `[]`                                | no       |

## Outputs

| Name                    | Description                                                                    |
|-------------------------|--------------------------------------------------------------------------------|
| static_ip_address       | Reserved external IPv4 in front of the LB. Null when `enable_ingress` is false. |
| url_map_name            | Main URL map name. Use in log sink filters and alert policy metric filters. Null when `enable_ingress` is false. |
| dashboard_id            | Monitoring dashboard ID. Null when `enable_ingress` is false, dashboard is disabled, or no customer_domain. |
| armor_policy_self_link  | Cloud Armor policy self link. Null when `enable_waf` is false.                 |
