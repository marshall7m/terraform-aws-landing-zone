data "aws_caller_identity" "current" {}

module "mut_cloudtrail" {
  source = "../../../../modules//cloudtrail"

  is_organization_trail      = true
  name                       = "mut-cloudtrail-logs"
  log_retention_days         = 1
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
}