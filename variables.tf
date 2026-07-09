variable "name" {
  type        = string
  description = "Prefix name for the destination"
}

variable "region" {
  type        = string
  default     = "ap-southeast-1"
  description = "AWS region"
}

variable "associate_secrets" {
  type = map(
    object({
      mount       = string
      secret_name = list(string)
    })
  )
  default     = {}
  description = "Map of vault kv secrets to sync to the AWS Secrets Manager destination. Remove an entry (or run terraform destroy) to unsync it."
}

variable "custom_tags" {
  type        = map(string)
  default     = {}
  description = "Custom tags to set on the secrets managed at the destination."
}

variable "secret_name_template" {
  type        = string
  default     = null
  description = "Template for external secret names. Leave null to use Vault's default (includes the mount accessor)."
}

variable "granularity" {
  type        = string
  default     = null
  description = "Level of information synced as a distinct resource: secret-path or secret-key. Null uses Vault's default."
}
