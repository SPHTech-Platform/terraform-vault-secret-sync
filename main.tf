#######################################
#                                     #
#    VAULT SECRET SYNC MANAGEMENT     #
#                                     #
#######################################

# New IAM keys are eventually-consistent; using one before it propagates makes
# store init fail with InvalidClientTokenId. Re-triggered on key rotation.
resource "time_sleep" "wait_for_key_propagation" {
  create_duration = "30s"

  triggers = {
    access_key_id = aws_iam_access_key.vault_secretsync.id
  }
}

resource "vault_secrets_sync_aws_destination" "this" {
  name              = local.destination_name
  access_key_id     = aws_iam_access_key.vault_secretsync.id
  secret_access_key = aws_iam_access_key.vault_secretsync.secret
  region            = var.region

  custom_tags          = var.custom_tags
  secret_name_template = var.secret_name_template
  granularity          = var.granularity

  depends_on = [time_sleep.wait_for_key_propagation]
}

# References the destination, so destroy removes associations first — teardown
# needs no delete flags.
resource "vault_secrets_sync_association" "this" {
  # jsonencode key avoids collisions when app_name/mount/secret_name contain "-".
  for_each = { for secret in local.associate_secrets : jsonencode([secret.app_name, secret.mount, secret.secret_name]) => secret }

  name        = vault_secrets_sync_aws_destination.this.name
  type        = vault_secrets_sync_aws_destination.this.type
  mount       = each.value.mount
  secret_name = each.value.secret_name
}
