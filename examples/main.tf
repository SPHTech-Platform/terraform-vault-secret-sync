# Syncs a throwaway KV v2 secret to AWS Secrets Manager. Provider config comes
# from the environment (VAULT_ADDR / VAULT_NAMESPACE / VAULT_TOKEN, AWS creds) —
# see .envrc.example. Teardown: terraform destroy.

data "aws_caller_identity" "current" {}

locals {
  region      = "ap-southeast-1"
  kv_mount    = "example-secret-sync"
  secret_name = "example"
}

provider "aws" {
  region = local.region
}

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
