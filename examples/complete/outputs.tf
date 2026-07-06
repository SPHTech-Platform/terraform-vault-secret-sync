output "synced_secret_path" {
  value       = "${var.kv_mount}/${var.secret_name}"
  description = "Vault KV path of the secret synced to AWS Secrets Manager."
}

output "aws_region" {
  value       = var.region
  description = "AWS region the Secrets Manager destination was created in."
}
