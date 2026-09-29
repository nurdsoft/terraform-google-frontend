# GCP Frontend Template

A Terraform orchestrator module that provisions the full edge stack for a
Cloud Run–backed web frontend on GCP by composing official Terraform Registry
modules.

## Features

- Orchestrates six Terraform Registry sub-modules into a single wrapper:
  - `nurdsoft/lb/google` — static IP, Serverless NEG, backend service, URL
    map, HTTP→HTTPS redirect, managed SSL cert, uptime checks, monitoring
    dashboard.
  - `nurdsoft/cloud-armor/google` — WAF policy attached to the LB backend
    service.
  - `nurdsoft/artifact-registry/google` — Docker repository for the
    frontend's container images.
  - `nurdsoft/project-logging/google` — log bucket + log sink routing the
    LB's request logs.
  - `nurdsoft/service-account/google` — pre-provisioned log-sink service
    account (roles granted only when logging is on).
  - `nurdsoft/alert-policies/google` — Cloud Monitoring alert policies for
    the frontend edge, with two built-in policies (`http_5xx_error_rate`,
    `uptime_check_failures`) baked in.
- Feature flags (`enable_ingress`, `enable_waf`, `enable_logging`,
  `enable_alerts`) to toggle each optional composition independently. All
  default to `true` — the wrapper is opinionated about what "the frontend
  edge" means.
- Automatic cross-module wiring:
  - When `enable_waf = true`, the Cloud Armor policy attaches to the LB
    backend service automatically.
  - When `enable_logging = true`, the log sink's filter targets the LB's
    `url_map_name` automatically.
  - When `enable_alerts = true`, the built-in policies target the LB's
    `url_map_name` and the configured `customer_domain` automatically.
- Re-exports the load-bearing sub-module outputs (`url_map_name`,
  `static_ip_address`, `dashboard_id`, `armor_policy_self_link`,
  `artifact_registry_repository_url`, `log_bucket_id`,
  `log_sink_service_account_email`, `alert_policy_names`, …).

---

## Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                    GCP Frontend Edge Template                          │
│                         (Orchestrator)                                 │
├───────────────────────────────────────────────────────────────────────┤
│                                                                        │
│  ┌──────────────────┐        ┌──────────────────┐                     │
│  │  Cloud Armor     │───────▶│  External HTTPS  │                     │
│  │  WAF Policy      │ attach │  Load Balancer   │                     │
│  │  (opt)           │        │                  │                     │
│  └──────────────────┘        └────────┬─────────┘                     │
│                                        │ url_map_name                  │
│                              ┌─────────┴─────────┐                     │
│                              ▼                   ▼                     │
│                    ┌──────────────────┐  ┌──────────────────┐         │
│                    │  Project Logging │  │  Alert Policies  │         │
│                    │  (log bucket +   │  │  (built-in +     │         │
│                    │   sink) (opt)    │  │   additional)    │         │
│                    └──────────────────┘  └──────────────────┘         │
│                                                                        │
│  ┌──────────────────┐        ┌──────────────────┐                     │
│  │  Artifact        │        │  Log-sink SA     │                     │
│  │  Registry        │        │  (roles gated    │                     │
│  │  (Docker)        │        │   on logging)    │                     │
│  └──────────────────┘        └──────────────────┘                     │
│                                                                        │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Usage

Consume via the Terraform Registry:

```hcl
module "frontend" {
  source  = "nurdsoft/frontend/google"
  version = "1.1.0"

  # Identity
  project_id             = "my-project"
  region                 = "us-central1"
  component              = "frontend"
  environment            = "dev"
  cloud_run_service_name = "my-frontend"
  customer_domain        = "app.example.com"

  # Artifact Registry
  artifact_registry_repo_id = "my-frontend-repo"

  # Cloud Armor
  waf_allowed_paths = ["/robots.txt", "/sitemap*"]

  # Alert policies
  notification_channels = [
    "projects/my-project/notificationChannels/1234567890",
  ]

  # All feature flags default to true; override to disable any sub-module.
  # enable_ingress = true
  # enable_waf     = true
  # enable_logging = true
  # enable_alerts  = true
}
```

See [`examples/complete`](./examples/complete) for a full working example.

**Constraint:** `enable_logging` and `enable_alerts` both require
`enable_ingress = true`, because the log-sink filter and the built-in alert
policies reference `module.external_https_lb[0].url_map_name`. The wrapper
enforces this via output preconditions.

---

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.3   |
| google    | >= 5.0   |

## Modules

| Name              | Source                             | Version |
|-------------------|------------------------------------|---------|
| cloud_armor       | nurdsoft/cloud-armor/google        | 1.0.0   |
| external_https_lb | nurdsoft/lb/google                 | 1.0.0   |
| artifact_registry | nurdsoft/artifact-registry/google  | 0.1.1   |
| log_stack         | nurdsoft/project-logging/google    | 1.0.1   |
| log_sink_sa       | nurdsoft/service-account/google    | 1.0.1   |
| alert_policies    | nurdsoft/alert-policies/google     | 1.1.0   |

## Inputs

### Identity

| Name         | Description                                  | Type     | Default        | Required |
|--------------|----------------------------------------------|----------|----------------|----------|
| project_id   | GCP project ID.                              | `string` | n/a            | yes      |
| region       | GCP region.                                  | `string` | `us-central1`  | no       |
| component    | Prefix for created resources.                | `string` | `frontend`     | no       |
| environment  | Env label stamped on alert-policy labels.    | `string` | `""`           | no       |

### External HTTPS load balancer

| Name                   | Description                                   | Type     | Default | Required |
|------------------------|-----------------------------------------------|----------|---------|----------|
| customer_domain        | Customer domain. Blank skips HTTPS setup.     | `string` | `""`    | no       |
| cloud_run_service_name | Name of the Cloud Run service the LB routes to. | `string` | n/a   | yes      |
| enable_ingress         | Enable the external HTTPS load balancer.      | `bool`   | `true`  | no       |
| uptime_check_path      | Path for the HTTPS uptime check.              | `string` | `/`     | no       |
| uptime_check_period    | Frequency of uptime checks (seconds).         | `number` | `300`   | no       |
| uptime_check_timeout   | Timeout for uptime checks (seconds).          | `number` | `10`    | no       |

### Cloud Armor WAF

| Name              | Description                                       | Type           | Default                             | Required |
|-------------------|---------------------------------------------------|----------------|-------------------------------------|----------|
| enable_waf        | Enable Cloud Armor policy and attach to LB.       | `bool`         | `true`                              | no       |
| waf_description   | Description on the Cloud Armor policy.            | `string`       | `Frontend WAF - Cloud Armor policy` | no       |
| waf_allowed_paths | Paths that bypass WAF block rules (`*` = prefix). | `list(string)` | `[]`                                | no       |

### Artifact Registry

| Name                       | Description                                             | Type     | Default | Required |
|----------------------------|---------------------------------------------------------|----------|---------|----------|
| artifact_registry_repo_id  | Repository ID for the frontend Docker repository.       | `string` | `""`    | no       |

### Project logging

| Name                  | Description                                                   | Type     | Default    | Required |
|-----------------------|---------------------------------------------------------------|----------|------------|----------|
| enable_logging        | Create log bucket + sink (requires enable_ingress).           | `bool`   | `true`     | no       |
| log_bucket_id_suffix  | Suffix appended to component to form the bucket ID and SA name. | `string` | `logs`   | no       |
| log_bucket_location   | Location for the log bucket.                                  | `string` | `global`   | no       |
| log_retention_days    | Retention period for the log bucket.                          | `number` | `30`       | no       |

### Alert policies

| Name                                     | Description                                                            | Type           | Default | Required |
|------------------------------------------|------------------------------------------------------------------------|----------------|---------|----------|
| enable_alerts                            | Create alert policies (requires enable_ingress).                       | `bool`         | `true`  | no       |
| enable_built_in_frontend_alert_policies  | Enable the http_5xx_error_rate + uptime_check_failures built-ins.      | `bool`         | `true`  | no       |
| notification_channels                    | Notification channel IDs attached to each alert policy.                | `list(string)` | `[]`    | no       |
| additional_alert_policies                | Extra policies merged on top of built-ins. Same shape as the sub-module. | `any`        | `{}`    | no       |

## Outputs

| Name                              | Description                                                                       |
|-----------------------------------|-----------------------------------------------------------------------------------|
| static_ip_address                 | Reserved external IPv4 in front of the LB. Null when `enable_ingress` is false.   |
| url_map_name                      | Main URL map name. Null when `enable_ingress` is false.                           |
| dashboard_id                      | Monitoring dashboard ID.                                                          |
| armor_policy_self_link            | Cloud Armor policy self link. Null when `enable_waf` is false.                    |
| artifact_registry_repository_id   | Artifact Registry repository ID.                                                  |
| artifact_registry_repository_url  | Artifact Registry pull URL.                                                       |
| log_bucket_id                     | Short ID of the log bucket. Null when logging is disabled.                        |
| log_bucket_resource_name          | Full resource name of the log bucket. Null when logging is disabled.              |
| log_sink_writer_identity          | Writer identity of the LB log sink. Null when logging is disabled.                |
| log_sink_service_account_email    | Email of the pre-provisioned log-sink service account.                            |
| alert_policy_ids                  | Map of alert-policy keys to GCP resource IDs. Empty when alerts are disabled.     |
| alert_policy_names                | Map of alert-policy keys to GCP resource names. Empty when alerts are disabled.   |

## Built-in alert policies

When `enable_alerts = true` and `enable_built_in_frontend_alert_policies = true`
(both default), two policies are created:

| Key                    | Severity | Trigger                                                           |
|------------------------|----------|-------------------------------------------------------------------|
| http_5xx_error_rate    | WARNING  | HTTP 5xx error rate on the LB exceeds 5% for 5 minutes.           |
| uptime_check_failures  | CRITICAL | The HTTPS uptime check for `customer_domain` fails for 60 seconds.|

Extend or replace via `additional_alert_policies`. Set
`enable_built_in_frontend_alert_policies = false` to opt out of the built-ins
entirely and supply your own set.

Note: this wrapper hardcodes `enable_built_in_policies = false` on the
`nurdsoft/alert-policies/google` sub-module — its built-ins are Cloud Run +
Cloud SQL policies, which are irrelevant to a frontend LB stack.
