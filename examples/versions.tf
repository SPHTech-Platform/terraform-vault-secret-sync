terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.25.0"
    }
  }
}
