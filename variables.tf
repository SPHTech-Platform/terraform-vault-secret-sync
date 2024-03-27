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
  description = "Map of vault kv to create secret sync association"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to set on the secrets managed at the destination"
}
