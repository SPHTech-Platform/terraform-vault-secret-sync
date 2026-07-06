# Complete example

Syncs a Vault KV v2 secret to AWS Secrets Manager using the module. The example
is self-contained: it creates a throwaway KV v2 mount + secret in Vault, stands
up an AWS Secrets Manager sync destination, and associates the secret. After
apply, the secret value is readable in AWS Secrets Manager.

## Prerequisites

- Vault Enterprise Secrets Sync activated on the target cluster
  (`vault read sys/sync/config` returns without error). Activation itself is a
  one-time write on `sys/activation-flags/secrets-sync/activate`.
- A Vault token (`VAULT_TOKEN`) whose policy grants **write** on the paths this
  config touches in `var.vault_namespace`:
  - `sys/sync/destinations/*` and their `associations/*` (used by the module);
  - `sys/mounts/<kv_mount>` and the KV secret path (only because this example
    creates a throwaway mount + secret — not needed when syncing a
    pre-existing secret).

  A namespace-scoped policy with these capabilities is sufficient. A full HCP
  admin (`hcp-root`) token also works but is **not required** — use least
  privilege.
- AWS credentials for the account the destination is created in, available to
  the AWS provider (SSO / environment / profile).
- Network reachability from where Terraform runs to `var.vault_address`
  (HCP Vault Dedicated private endpoints require VPN / peering).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # set vault_address
export VAULT_TOKEN=<admin-token>
terraform init
terraform apply
```

Verify the value landed in AWS Secrets Manager:

```bash
aws secretsmanager list-secrets --region ap-southeast-1 \
  --query "SecretList[?contains(Name,'example')].Name" --output text
aws secretsmanager get-secret-value --region ap-southeast-1 \
  --secret-id <name-from-above> --query SecretString --output text
```

> **Note on the first apply:** newly created IAM access keys are eventually
> consistent in AWS. The module waits for the key to propagate before Vault
> initializes the store; without that wait an apply can fail with
> `InvalidClientTokenId`. If you hit it on an older module version, simply
> re-run `terraform apply`.

## Teardown

Associations must be removed before the destination can be deleted, so tear down
in order:

```bash
terraform apply -var delete_all_secret_associations=true
terraform apply -var delete_all_secret_associations=true -var delete_sync_destination=true
terraform destroy
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
