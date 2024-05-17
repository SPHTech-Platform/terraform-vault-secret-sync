#######################################
#                                     #
#    AWS IAM USER - ACCESS KEY MGMT   #
#                                     #
#######################################

resource "random_id" "this" {
  byte_length = 8
}

module "iam_user_secretsync" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 5.32.0"

  name = local.destination_name

  create_iam_access_key         = false
  create_iam_user_login_profile = false
  create_user                   = true
  force_destroy                 = true
}

resource "aws_iam_access_key" "vault_secretsync" {
  user = module.iam_user_secretsync.iam_user_name

  lifecycle {
    create_before_destroy = true

    replace_triggered_by = [
      null_resource.rotate_access_key
    ]
  }
}

resource "time_rotating" "iam_user_secretsync_access_key" {
  rotation_days = local.iam_key_rotation_days
}

resource "null_resource" "rotate_access_key" {
  triggers = {
    rotating_id = time_rotating.iam_user_secretsync_access_key.id
  }
}

module "iam_group_secretsync" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 5.32.0"

  name         = "vault-ent-secret-sync-${random_id.this.hex}"
  create_group = true

  enable_mfa_enforcement = false
  group_users            = [module.iam_user_secretsync.iam_user_name]

  custom_group_policies = [
    {
      name   = "vault-ent-secret-sync-${random_id.this.hex}"
      policy = data.aws_iam_policy_document.vault_ent_secrets_manager_access.json
    }
  ]
}
