output "destination_name" {
  description = "Name of the AWS Secrets Manager sync destination."
  value       = vault_secrets_sync_aws_destination.this.name
}

output "sync_status" {
  description = "Per-association sync status, keyed by <app>-<secret_name>."
  value       = { for k, assoc in vault_secrets_sync_association.this : k => assoc.sync_status }
}
