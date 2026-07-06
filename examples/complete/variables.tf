variable "vault_address" {
  type        = string
  description = "Vault cluster address. For HCP Vault Dedicated use the cluster endpoint URL (reachable from where Terraform runs)."
}

variable "vault_namespace" {
  type        = string
  default     = "admin"
  description = "Vault namespace the source secret + sync destination live in. HCP Vault Dedicated root is `admin`; use a child path (e.g. admin/team/app) as needed."
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region for the Secrets Manager destination."
}

variable "name" {
  type        = string
  default     = "example-secret-sync"
  description = "Destination name prefix (the module appends region + a random suffix)."
}

variable "kv_mount" {
  type        = string
  default     = "example-secret-sync"
  description = "Path of the throwaway KV v2 mount this example creates."
}

variable "secret_name" {
  type        = string
  default     = "example"
  description = "Name of the throwaway KV v2 secret this example creates and syncs."
}

variable "delete_all_secret_associations" {
  type        = bool
  default     = false
  description = "Teardown step 1: remove all secret associations (must be true before delete_sync_destination)."
}

variable "delete_sync_destination" {
  type        = bool
  default     = false
  description = "Teardown step 2: delete the AWS Secrets Manager destination."
}
