# End-to-end example: sync a Vault KV v2 secret to AWS Secrets Manager.
#
# Self-contained — creates a throwaway KV v2 mount + secret, then syncs it.
# Edit the locals below, then `terraform init && terraform apply`.
#
# Auth (supply via environment, never hard-coded):
#   export VAULT_TOKEN=<token with write on sys/sync + the target namespace>
#   AWS credentials via your usual mechanism (SSO / env / profile)
#
# Teardown (associations must go before the destination):
#   in the module block set delete_all_secret_associations = true, apply;
#   then also set delete_sync_destination = true, apply; then terraform destroy.

data "aws_caller_identity" "current" {}

locals {
  region          = "ap-southeast-1"
  vault_address   = "https://<cluster>.private.vault.<cluster-uuid>.aws.hashicorp.cloud:8200"
  vault_namespace = "admin"
  kv_mount        = "example-secret-sync"
  secret_name     = "example"
}

provider "aws" {
  region = local.region
}

provider "vault" {
  address   = local.vault_address
  namespace = local.vault_namespace
}

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
