#######################################
#                                     #
#    VAULT SECRET SYNC MANAGEMENT     #
#                                     #
#######################################

# Wait for the freshly-created IAM access key to propagate in AWS before Vault
# uses it. New keys are eventually-consistent; without this, Vault initializes
# the aws-sm store with a key AWS does not yet recognize and returns
# `InvalidClientTokenId` (AWS STS 403 -> Vault 500). Re-created on key rotation
# (trigger below) so the update path waits too.
resource "time_sleep" "wait_for_key_propagation" {
  create_duration = "30s"

  triggers = {
    access_key_id = aws_iam_access_key.vault_secretsync.id
  }
}

# Vault -> AWS Secrets Manager destination (one per region).
resource "vault_secrets_sync_aws_destination" "this" {
  name              = local.destination_name
  access_key_id     = aws_iam_access_key.vault_secretsync.id
  secret_access_key = aws_iam_access_key.vault_secretsync.secret
  region            = var.region

  # Do not hand the key to Vault until it has propagated in AWS.
  depends_on = [time_sleep.wait_for_key_propagation]
}

# Vault secret -> AWS SM association. Removing an entry from associate_secrets
# (or `terraform destroy`) unsyncs it; the association is destroyed before the
# destination because it references the destination, so teardown needs no flags.
resource "vault_secrets_sync_association" "this" {
  for_each = { for secret in local.associate_secrets : "${secret.app_name}-${secret.secret_name}" => secret }

  name        = vault_secrets_sync_aws_destination.this.name
  type        = vault_secrets_sync_aws_destination.this.type
  mount       = each.value.mount
  secret_name = each.value.secret_name
}
