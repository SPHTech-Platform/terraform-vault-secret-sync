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
