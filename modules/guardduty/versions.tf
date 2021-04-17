terraform {
  required_version = ">= 0.15.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42"
      # configuration_aliases = [
      #   aws.gd,
      #   aws.s3
      # ]
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

variable "logs_org_role_arn" {
  type = string
}

provider "aws" {
  assume_role {
    role_arn = var.logs_org_role_arn
  }
  alias = "logs"
}