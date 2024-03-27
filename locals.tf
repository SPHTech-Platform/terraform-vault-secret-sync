locals {
  age_in_days      = timeadd(plantimestamp(), "-2160h") # 90 days (90*24 hours)
  destination_name = "${var.name}-${var.region}-${random_id.this.hex}"

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
