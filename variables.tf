variable "name" {
  description = "Prefix name for the destination"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "associate_secrets" {
  description = "Map of Vault KV secrets to sync to the AWS Secrets Manager destination. The map key is a free-form label (any unique string): it only groups entries in your config and does not affect the synced secret. Remove an entry (or run terraform destroy) to unsync it."
  type = map(
    object({
      mount       = string
      secret_name = set(string)
    })
  )
  default = {}
}

variable "custom_tags" {
  description = "Custom tags to set on the secrets managed at the destination."
  type        = map(string)
  default     = {}
}

variable "secret_name_template" {
  description = "Template for external secret names. Leave null to use Vault's default (includes the mount accessor). The literal prefix before the first template action scopes the sync user's IAM policy."
  type        = string
  default     = null

  validation {
    condition = var.secret_name_template == null || (
      length(trimspace(split("{{", var.secret_name_template)[0])) > 0 &&
      length(regexall("\\*", split("{{", var.secret_name_template)[0])) == 0
    )
    error_message = "secret_name_template must start with a literal, non-blank prefix that contains no \"*\" (e.g. \"vault/bastion/{{ .SecretPath }}\"). The prefix scopes the IAM policy, and the policy already appends a wildcard."
  }
}

variable "additional_secret_name_prefixes" {
  description = "Extra AWS Secrets Manager name prefixes to allow in the sync user's IAM policy. Needed when secrets were synced under a previous secret_name_template: Vault deletes the external secret on unsync, so without the old prefix those associations cannot be removed and the destination cannot be deleted."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for prefix in var.additional_secret_name_prefixes :
      length(trimspace(prefix)) > 0 && length(regexall("\\*", prefix)) == 0
    ])
    error_message = "Each additional_secret_name_prefixes entry must be non-blank and contain no \"*\". The IAM policy appends a wildcard, so a blank or wildcard entry would grant access to every secret in the account."
  }
}

variable "granularity" {
  description = "Level of information synced as a distinct resource: secret-path or secret-key. Null uses Vault's default."
  type        = string
  default     = null

  validation {
    condition     = var.granularity == null || contains(["secret-path", "secret-key"], coalesce(var.granularity, "secret-path"))
    error_message = "granularity must be \"secret-path\" or \"secret-key\"."
  }
}
