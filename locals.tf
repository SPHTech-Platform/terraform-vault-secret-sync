locals {
  # checks for keys older than 30 days
  age_in_days           = timeadd(plantimestamp(), "-720h") # 30 days (30*24 hours)
  iam_key_rotation_days = 30                                # rotate key if older than 30 days
  destination_name      = "${var.name}-${var.region}-${random_id.this.hex}"

  associate_secrets = flatten([
    for app_name, secret in var.associate_secrets : [
      for secret_name in secret.secret_name : {
        app_name    = app_name
        mount       = secret.mount
        secret_name = secret_name
      }
    ]
  ])
}
