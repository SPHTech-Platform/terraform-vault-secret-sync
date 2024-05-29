locals {
  # checks for keys older than 30 days
  age_in_days             = timeadd(plantimestamp(), "-720h") # 30 days (30*24 hours)
  iam_key_rotation_days   = 30                                # rotate key if older than 30 days
  sync_base_path          = "sys/sync/destinations"
  destination_name        = "${var.name}-${var.region}-${random_id.this.hex}"
  delete_sync_destination = alltrue([var.delete_all_secret_associations, var.delete_sync_destination])

  associate_secrets = flatten([
    for app_name, secret in var.associate_secrets : [
      for secret_name in secret.secret_name : {
        app_name    = app_name
        mount       = secret.mount
        secret_name = secret_name
      }
    ]
  ])

  unassociate_secrets = flatten([
    for app_name, secret in var.unassociate_secrets : [
      for secret_name in secret.secret_name : {
        app_name    = app_name
        mount       = secret.mount
        secret_name = secret_name
      }
    ]
  ])
}
