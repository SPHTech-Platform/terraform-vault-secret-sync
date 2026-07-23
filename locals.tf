locals {
  # checks for keys older than 30 days
  age_in_days           = timeadd(plantimestamp(), "-720h") # 30 days (30*24 hours)
  iam_key_rotation_days = 30                                # rotate key if older than 30 days
  destination_name      = "${var.name}-${var.region}-${random_id.this.hex}"

  # Vault applies this template when secret_name_template is unset.
  default_secret_name_template = "vault/{{ .MountAccessor }}/{{ .SecretPath }}"

  # Scope the IAM policy to the literal prefix of the name template (everything
  # before the first template action). Vault deletes the external secret on
  # unsync, so a prefix the policy does not cover leaves associations stuck.
  secret_name_prefixes = distinct(concat(
    [split("{{", coalesce(var.secret_name_template, local.default_secret_name_template))[0]],
    var.additional_secret_name_prefixes,
  ))

  associate_secrets = flatten([
    for secret in var.associate_secrets : [
      for secret_name in secret.secret_name : {
        mount       = secret.mount
        secret_name = secret_name
      }
    ]
  ])
}
