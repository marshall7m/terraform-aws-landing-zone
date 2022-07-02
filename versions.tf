terraform {
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.41.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.1.0"
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = local.logs_org_role_arn
  }
  alias = "logs"
}

provider "aws" {
  assume_role {
    role_arn = local.cfg_org_role_arn
  }
  alias = "cfg"
}