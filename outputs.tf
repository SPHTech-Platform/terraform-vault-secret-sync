output "destination_name" {
  description = "Name of the AWS Secrets Manager sync destination."
  value       = vault_secrets_sync_aws_destination.this.name
}
