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
      secret_name = list(string)
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
  description = "Template for external secret names. Leave null to use Vault's default (includes the mount accessor)."
  type        = string
  default     = null
}

variable "granularity" {
  description = "Level of information synced as a distinct resource: secret-path or secret-key. Null uses Vault's default."
  type        = string
  default     = null
}
