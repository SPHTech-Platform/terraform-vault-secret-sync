terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.67.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.23.0"
    }
  }
}
