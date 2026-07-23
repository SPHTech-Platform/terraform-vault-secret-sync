# Vault Enterprise Secret Sync
Create and manage [Vault Enterprise Secret Sync](https://developer.hashicorp.com/vault/docs/sync).

## Note
- This module currently only supports [AWS Secrets Manager destination](https://developer.hashicorp.com/vault/docs/sync/awssm). Other [secret sync destinations](https://developer.hashicorp.com/vault/docs/sync#destinations) will be supported in the future.
- The destination and associations are managed with the first-class `vault_secrets_sync_aws_destination` and `vault_secrets_sync_association` resources (Vault 1.16+ Enterprise). Removal is ordered by the resource graph — associations are destroyed before the destination — so no manual delete flags are needed.

## Usage
Create the Vault Secret Sync destination and secret associations:
```terraform
module "vault_secretsync" {
  source  = "SPHTech-Platform/secret-sync/vault"
  version = "~> 1.0"

  name = "vault-ss"

  # The map key (foo, hello) is a free-form label — any unique string. It only
  # groups entries in your config; it does not affect the synced secret.
  associate_secrets = {
    foo = {
      mount       = "mount_foo"
      secret_name = ["foo_secret"]
    }
    hello = {
      mount       = "mount_hello"
      secret_name = [
        "hello_secret_1",
        "hello_secret_2",
      ]
    }
  }
}
```

**Unsync a secret:** remove it from `associate_secrets` (or drop a `secret_name` from the list) and apply — the corresponding association is destroyed, which unsyncs it. The destination and other associations are untouched.

## Secret naming and IAM scope

Vault — not Terraform — owns the lifecycle of the AWS Secrets Manager secret. Vault creates, tags, and **deletes** it using the IAM user this module provisions. The module therefore scopes that user's policy to the literal prefix of `secret_name_template`:

| `secret_name_template` | IAM resource scope |
| --- | --- |
| unset (Vault default) | `secret:vault/*` |
| `vault/bastion/{{ .SecretPath }}` | `secret:vault/bastion/*` |
| `prefix-{{ .SecretPath }}` | `secret:prefix-*` |

> **Changing `secret_name_template` after secrets are synced is hazardous.** On unsync Vault derives the external secret name from the *current* template, so secrets written under an older prefix fall outside the IAM policy. The delete is denied, the association can never be removed, and the destination then cannot be deleted:
> `failed to delete destination: sync destination still contains associations`.

To change the template safely, unsync first (remove the entries from `associate_secrets`, apply), then change it.

If you are already stuck, add the literal prefix of the **previous** template so Vault can complete the unsync, apply, then destroy normally. For example, when secrets were first synced with `/bastion/{{ .SecretPath }}` and the template is now `vault/bastion/{{ .SecretPath }}`:

```terraform
secret_name_template            = "vault/bastion/{{ .SecretPath }}" # current
additional_secret_name_prefixes = ["/bastion/"]                     # literal prefix of the old template
```

Each entry must match the literal prefix of the names actually stored in AWS Secrets Manager. Check them with `vault read sys/sync/destinations/aws-sm/<destination>/associations` and look at `external_name`.

As a last resort you can delete the destination out of band, which orphans any secrets already synced:

```bash
vault delete sys/sync/destinations/aws-sm/<destination> purge=true force_delete=true
```

**Tear everything down:** run `terraform destroy`. Terraform destroys the associations first (each references the destination), then the destination, then the IAM user/key — no flags, no multi-step apply.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 4.2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 4.2.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_iam_group_secretsync"></a> [iam\_group\_secretsync](#module\_iam\_group\_secretsync) | terraform-aws-modules/iam/aws//modules/iam-group-with-policies | ~> 5.32.0 |
| <a name="module_iam_user_secretsync"></a> [iam\_user\_secretsync](#module\_iam\_user\_secretsync) | terraform-aws-modules/iam/aws//modules/iam-user | ~> 5.32.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_access_key.vault_secretsync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [null_resource.rotate_access_key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [time_rotating.iam_user_secretsync_access_key](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [time_sleep.wait_for_key_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [vault_secrets_sync_association.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/secrets_sync_association) | resource |
| [vault_secrets_sync_aws_destination.this](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/secrets_sync_aws_destination) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.vault_ent_secrets_manager_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_associate_secrets"></a> [associate\_secrets](#input\_associate\_secrets) | Map of Vault KV secrets to sync to the AWS Secrets Manager destination. The map key is a free-form label (any unique string): it only groups entries in your config and does not affect the synced secret. Remove an entry (or run terraform destroy) to unsync it. | <pre>map(<br/>    object({<br/>      mount       = string<br/>      secret_name = list(string)<br/>    })<br/>  )</pre> | `{}` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Custom tags to set on the secrets managed at the destination. | `map(string)` | `{}` | no |
| <a name="input_granularity"></a> [granularity](#input\_granularity) | Level of information synced as a distinct resource: secret-path or secret-key. Null uses Vault's default. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Prefix name for the destination | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"ap-southeast-1"` | no |
| <a name="input_secret_name_template"></a> [secret\_name\_template](#input\_secret\_name\_template) | Template for external secret names. Leave null to use Vault's default (includes the mount accessor). | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_destination_name"></a> [destination\_name](#output\_destination\_name) | Name of the AWS Secrets Manager sync destination. |
<!-- END_TF_DOCS -->
