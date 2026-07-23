data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "vault_ent_secrets_manager_access" {
  statement {
    sid = "VaultEntSecretsManagerAccess"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:DeleteSecret",
      "secretsmanager:RestoreSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
    ]
    resources = [
      for prefix in local.secret_name_prefixes :
      "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${prefix}*"
    ]
  }
}
