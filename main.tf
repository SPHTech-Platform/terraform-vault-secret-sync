#######################################
#                                     #
#    VAULT SECRET SYNC MANAGEMENT     #
#                                     #
#######################################

resource "vault_secrets_sync_aws_destination" "aws" {
  name              = local.destination_name
  access_key_id     = aws_iam_access_key.vault_secretsync.id
  secret_access_key = aws_iam_access_key.vault_secretsync.secret
  region            = data.aws_region.current.name

  custom_tags = var.tags
}

resource "vault_secrets_sync_association" "this" {
  for_each = { for secret in local.associate_secrets : "${secret.app_name}-${secret.secret_name}" => secret }

  name        = vault_secrets_sync_aws_destination.aws.name
  type        = vault_secrets_sync_aws_destination.aws.type
  mount       = each.value.mount
  secret_name = each.value.secret_name
}
