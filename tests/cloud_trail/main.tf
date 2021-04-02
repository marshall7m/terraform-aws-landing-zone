data "aws_caller_identity" "current" {}

provider "aws" {
  alias   = "master"
  profile = "root-iam"
}

provider "aws" {
  alias   = "logs"
  profile = "logs-admin"
}

module "mut_cloud_trail" {
  source = "../../modules//cloud_trail"
  providers = {
    aws.master = aws.master
    aws.logs   = aws.logs
  }
  log_retention_days     = 1
  trusted_kms_admin_arns = [data.aws_caller_identity.current.id]
}