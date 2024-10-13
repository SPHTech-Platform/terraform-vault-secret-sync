variable "name" {
  description = "Prefix name for the destination"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_role_arn" {
  description = "AWS IAM role to assume"
  type        = string
  default     = null
}

variable "aws_role_external_id" {
  description = "Extra protection that must match trust policy granting access to the AWS IAM role ARN"
  type        = string
  default     = null
}

variable "secrets" {
  type = map(
    object({
      mount       = string
      secret_name = list(string)
    })
  )
  default     = {}
  description = "Map of vault kv to create secret sync association"
}

variable "secret_name_template" {
  description = "Template describing how to generate external secret names."
  type        = string
  default     = "vault_{{ .MountAccessor | lowercase }}_{{ .SecretPath | lowercase }}"
}

variable "custom_tags" {
  description = "Custom tags to set on the secret managed at the destination"
  type        = map(string)
  default     = {}
}
