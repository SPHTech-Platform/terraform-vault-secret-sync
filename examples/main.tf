# End-to-end example: sync a Vault KV v2 secret to AWS Secrets Manager.
#
# Self-contained — creates a throwaway KV v2 mount + secret, then syncs it.
#
# Provider config is read from the environment, so no cluster-specific or
# sensitive values live in this file. Set them before running — via a gitignored
# .envrc with direnv (see .envrc.example), or plain exports:
#   export VAULT_ADDR=...        # cluster endpoint, reachable from where you run
#   export VAULT_NAMESPACE=...   # e.g. admin, or a child namespace
#   export VAULT_TOKEN=...       # token with sys/sync write in that namespace
#   export AWS_REGION=ap-southeast-1
#   AWS credentials via SSO / profile / env
#
# Run:      terraform init && terraform apply
# Teardown: terraform destroy   (associations are removed before the destination
#           automatically — no delete flags)

data "aws_caller_identity" "current" {}

locals {
  region      = "ap-southeast-1"
  kv_mount    = "example-secret-sync"
  secret_name = "example"
}

# Credentials from the environment (AWS_PROFILE / AWS_ACCESS_KEY_ID / ...).
provider "aws" {
  region = local.region
}

# Address, namespace, and token from VAULT_ADDR / VAULT_NAMESPACE / VAULT_TOKEN.
provider "vault" {}

resource "vault_mount" "this" {
  path        = local.kv_mount
  type        = "kv"
  options     = { version = "2" }
  description = "Example KV v2 mount for the secret-sync module. Safe to delete."
}

resource "vault_kv_secret_v2" "this" {
  mount     = vault_mount.this.path
  name      = local.secret_name
  data_json = jsonencode({ example = "hello-from-vault-secrets-sync" })
}

module "secret_sync" {
  source = "../"

  name   = "example-secret-sync"
  region = local.region

  associate_secrets = {
    example = {
      mount       = vault_mount.this.path
      secret_name = [local.secret_name]
    }
  }

  depends_on = [vault_kv_secret_v2.this]
}
