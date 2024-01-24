check "check_iam_key_age_vault_secretsync" {
  assert {
    condition = (
      timecmp(coalesce(aws_iam_access_key.vault_secretsync.create_date, local.age_in_days), local.age_in_days) > 0
    )
    error_message = format("The IAM key for metrics user %s is older than 40 days. Please rotate the key.",
    aws_iam_user.vault_secretsync.name)
  }
}
