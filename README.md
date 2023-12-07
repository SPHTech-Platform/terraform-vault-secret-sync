# Vault Enterprise Secret Sync

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.67.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.29.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.10.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.23.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_group_secretsync"></a> [iam\_group\_secretsync](#module\_iam\_group\_secretsync) | terraform-aws-modules/iam/aws//modules/iam-group-with-policies | ~> 5.32.0 |
| <a name="module_iam_user_secretsync"></a> [iam\_user\_secretsync](#module\_iam\_user\_secretsync) | terraform-aws-modules/iam/aws//modules/iam-user | ~> 5.32.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.vault_secretsync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [null_resource.rotate_access_key](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [time_rotating.iam_user_secretsync_access_key](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [time_sleep.wait_5_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [vault_generic_endpoint.create_association_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |
| [vault_generic_endpoint.create_destination_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |
| [vault_generic_endpoint.remove_all_association_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |
| [vault_generic_endpoint.remove_some_association_sync](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_endpoint) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.vault_ent_secrets_manager_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_associate_secrets"></a> [associate\_secrets](#input\_associate\_secrets) | Map of vault kv to create secret sync association | <pre>map(<br>    object({<br>      mount       = string<br>      secret_name = list(string)<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_delete_all_secret_associations"></a> [delete\_all\_secret\_associations](#input\_delete\_all\_secret\_associations) | Delete the secret associations | `bool` | `false` | no |
| <a name="input_delete_sync_destination"></a> [delete\_sync\_destination](#input\_delete\_sync\_destination) | Delete the sync destination. Secret associations must be removed beforehand. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Prefix name for the destination | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"ap-southeast-1"` | no |
| <a name="input_unassociate_secrets"></a> [unassociate\_secrets](#input\_unassociate\_secrets) | Map of vault kv to remove secret sync association | <pre>map(<br>    object({<br>      mount       = string<br>      secret_name = list(string)<br>    })<br>  )</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
