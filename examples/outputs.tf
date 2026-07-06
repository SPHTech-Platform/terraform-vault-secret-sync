output "account_id" {
  description = "Account ID that owns the AWS Secrets Manager destination"
  value       = data.aws_caller_identity.current.account_id
}

output "synced_secret_path" {
  description = "Vault KV path of the secret synced to AWS Secrets Manager"
  value       = "${local.kv_mount}/${local.secret_name}"
}
