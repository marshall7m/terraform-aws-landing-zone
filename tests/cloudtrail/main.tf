data "aws_caller_identity" "current" {}

provider "aws" {
  alias   = "master"
  profile = "root-iam"
  region = "us-west-2"
}

provider "aws" {
  alias   = "logs"
  profile = "logs-admin"
  region = "us-west-2"
}

module "mut_cloudtrail" {
  source = "../../modules//cloudtrail"
  providers = {
    aws.ct = aws.master
    aws.s3   = aws.logs
  }
  is_organization_trail = true
  name = "mut-cloudtrail-logs"
  log_retention_days     = 1
  trusted_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
}