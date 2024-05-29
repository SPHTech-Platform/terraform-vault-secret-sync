check "check_iam_key_age_vault_secretsync" {
  assert {
    condition = (
      timecmp(coalesce(aws_iam_access_key.vault_secretsync.create_date, local.age_in_days), local.age_in_days) > 0
    )
    error_message = format("The IAM key for metrics user %s is older than 30 days. Please rotate the key.",
    module.iam_user_secretsync.iam_user_name)
  }
}
