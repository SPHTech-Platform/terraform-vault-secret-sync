#######################################
#                                     #
#    VAULT SECRET SYNC MANAGEMENT     #
#                                     #
#######################################

# Create Vault -> AWS SM destination
# Only need to create one destination per AWS region
resource "vault_secrets_sync_aws_destination" "this" {
  name                 = local.destination_name # unique name of the AWS destination
  access_key_id        = aws_iam_access_key.vault_secretsync.id
  secret_access_key    = aws_iam_access_key.vault_secretsync.secret
  region               = var.aws_region
  role_arn             = var.aws_role_arn
  external_id          = var.aws_role_external_id
  secret_name_template = var.secret_name_template
  custom_tags          = var.custom_tags
}

# Create Vault Secret -> AWS SM association
resource "vault_secrets_sync_association" "this" {
  for_each = { for secret in local.secrets : "${secret.app_name}-${secret.secret_name}" => secret }

  name        = vault_secrets_sync_aws_destination.this.name
  type        = vault_secrets_sync_aws_destination.this.type
  mount       = each.value.mount
  secret_name = each.value.secret_name
}
