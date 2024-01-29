locals {
  age_in_days             = timeadd(plantimestamp(), "-2160h") # 90 days (90*24 hours)
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
