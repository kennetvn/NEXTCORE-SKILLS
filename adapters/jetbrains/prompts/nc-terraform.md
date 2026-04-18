---
description: Infrastructure-as-code with Terraform / OpenTofu. Use when provisioning cloud resources (AWS/GCP/Azure), managing remote state, writing reusable modules, or migrating manually-created infra into IaC.
---

# Terraform / OpenTofu Skill

Default to OpenTofu (FOSS fork) for new projects unless org standardized on Terraform. Syntax + concepts identical; this skill applies to both.

## Project layout

```
infra/
├── envs/
│   ├── dev/
│   │   ├── main.tf        # composes modules with dev values
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── backend.tf     # remote state config
│   ├── staging/
│   └── prod/
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── api-service/
└── README.md
```

One state file per env. Modules are pure (no env-specific defaults).

## Remote state (mandatory for teams)

```hcl
# backend.tf — never put creds here
terraform {
  required_version = ">= 1.6.0"
  backend "s3" {
    bucket         = "myorg-tfstate"
    key            = "envs/prod/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tfstate-lock"
    encrypt        = true
  }
}
```

DynamoDB table provides state locking → prevents concurrent applies stepping on each other.

## Module pattern

```hcl
# modules/api-service/main.tf
variable "name"          { type = string }
variable "image"         { type = string }
variable "replicas"      { type = number, default = 2 }
variable "vpc_id"        { type = string }
variable "subnet_ids"    { type = list(string) }

resource "aws_ecs_service" "this" { ... }

output "service_arn" { value = aws_ecs_service.this.id }
output "endpoint"    { value = aws_lb.this.dns_name }
```

Used by env:
```hcl
# envs/prod/main.tf
module "api" {
  source     = "../../modules/api-service"
  name       = "api-prod"
  image      = "registry.example.com/api:1.2.3"
  replicas   = 10
  vpc_id     = module.vpc.id
  subnet_ids = module.vpc.private_subnet_ids
}
```

## Workflow

```bash
# Init (downloads providers, sets up backend)
tofu init           # or: terraform init

# Plan (dry run, shows changes)
tofu plan -out=tfplan

# Apply (executes plan)
tofu apply tfplan

# Destroy (when retiring env)
tofu destroy -target=module.api    # selective
tofu destroy                        # entire env (careful!)

# State manipulation
tofu state list                     # what's tracked
tofu state show aws_instance.web
tofu state mv old_addr new_addr     # rename without recreating
tofu state rm <addr>                # untrack (resource still exists)
tofu import <addr> <real-id>        # adopt manually-created resource
```

## Importing existing infrastructure

When migrating from click-ops to IaC:

1. Write the resource block matching the real resource (use AWS console / `aws` cli to discover attrs)
2. `tofu import aws_instance.web i-1234567890abcdef0`
3. Run `tofu plan` — should show NO changes if blocks match reality
4. If changes show: tweak the resource block until plan is clean
5. Repeat for each resource

For bulk imports: use `terraformer` or AWS Application Composer.

## Common patterns

### Conditional resource

```hcl
resource "aws_cloudwatch_log_group" "logs" {
  count = var.enable_logging ? 1 : 0
  name  = "/myapp/${var.name}"
}
```

### Iterating with `for_each`

```hcl
resource "aws_iam_user" "team" {
  for_each = toset(["alice", "bob", "charlie"])
  name     = each.key
}
```

### Locals for repeated values

```hcl
locals {
  common_tags = {
    Project     = "myapp"
    Environment = var.env
    ManagedBy   = "terraform"
  }
}

resource "aws_instance" "web" {
  tags = local.common_tags
}
```

### Sensitive outputs

```hcl
output "db_password" {
  value     = aws_secretsmanager_secret_version.db.secret_string
  sensitive = true
}
```

## State drift recovery

When someone changes things in console:

```bash
tofu plan                        # shows drift
# Decision: adopt or revert?
# Adopt: update .tf to match reality
# Revert: tofu apply (restores .tf state)
```

Prevention: lock down console access (read-only IAM for most), enforce IaC-only changes via policy.

## Multi-env strategies

| Pattern | Pros | Cons |
|---|---|---|
| Separate state files (per env) | Clean isolation, blast radius small | Code duplication risk (mitigate with modules) |
| Workspaces (single backend) | Less files | Easy to apply to wrong env, shared state |
| Separate root modules per env | Most flexible | Most boilerplate |

Recommendation: separate state per env (option 1).

## Security must-haves

- Never commit `.tfstate` — has secrets
- `.gitignore`: `*.tfstate*`, `.terraform/`, `*.tfvars` (especially `*.auto.tfvars`)
- Use OIDC for CI provider auth (no long-lived keys)
- Run `tofu plan` in CI on every PR; require approval before apply
- `tflint` + `tfsec` / `checkov` in CI for misconfigurations

## Anti-patterns

- Manual changes to managed resources (drift)
- One mega state file for entire org (slow plans, blast radius)
- Hardcoded values where variables fit
- Module so generic it has 30+ variables (split it)
- No `.terraform.lock.hcl` committed (provider versions drift)
- Running apply with auto-approve in prod CI
- Storing secrets in `.tf` files

## Integration

- `nc-kubernetes` — provision EKS/GKE cluster, then hand off
- `nc-ci-cd` — GitHub Actions terraform plan-on-PR + apply-on-merge
- `nc-security` — tfsec / checkov scans for misconfig
- `nc-backup-recovery` — state file backup strategy
- `nc-observability` — provisioning observability stack
