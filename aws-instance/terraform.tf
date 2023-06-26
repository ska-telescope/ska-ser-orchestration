terraform {
  required_version = "~>1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.16"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.1.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>2.2.2"
    }
  }
}