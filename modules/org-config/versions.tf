terraform {
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.42"
      configuration_aliases = [
        aws.master
      ]
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = var.cfg_role_arn
  }
}

provider "aws" {
  assume_role {
    role_arn = var.logs_role_arn
  }
  alias = "logs"
}
