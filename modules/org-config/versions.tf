terraform {
  required_version = ">= 0.15.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42"
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = var.cfg_role_arn
  }
}