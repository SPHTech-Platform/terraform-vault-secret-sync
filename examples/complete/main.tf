###############################################################################
# Complete example: sync a Vault KV v2 secret to AWS Secrets Manager.
#
# This example is self-contained: it creates a throwaway KV v2 mount + secret
# in Vault, then uses the module to stand up an AWS Secrets Manager sync
# destination and associate the secret. After apply, the secret value appears
# in AWS Secrets Manager. Tear down with the delete_* variables (see README).
#
# No credentials are hard-coded. Supply them via the environment before apply:
#   export VAULT_TOKEN=<token with write on sys/sync + the target namespace>
#   AWS credentials via your usual mechanism (SSO / env / profile)
###############################################################################

provider "aws" {
  region = var.region
}

provider "vault" {
  address   = var.vault_address
  namespace = var.vault_namespace
}

# --- Throwaway source secret (delete after testing) ------------------------

resource "vault_mount" "this" {
  path        = var.kv_mount
  type        = "kv"
  options     = { version = "2" }
  description = "Example KV v2 mount for the secret-sync module. Safe to delete."
}

resource "vault_kv_secret_v2" "this" {
  mount = vault_mount.this.path
  name  = var.secret_name

  data_json = jsonencode({
    example = "hello-from-vault-secrets-sync"
  })
}

# --- Sync it to AWS Secrets Manager ----------------------------------------

module "secret_sync" {
  source = "../.."

  name   = var.name
  region = var.region

  associate_secrets = {
    example = {
      mount       = vault_mount.this.path
      secret_name = [var.secret_name]
    }
  }

  # Teardown levers (see README). Leave false for setup.
  delete_all_secret_associations = var.delete_all_secret_associations
  delete_sync_destination        = var.delete_sync_destination

  # Ensure the source secret exists before the association is created.
  depends_on = [vault_kv_secret_v2.this]
}
