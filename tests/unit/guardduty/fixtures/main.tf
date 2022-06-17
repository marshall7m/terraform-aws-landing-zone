data "aws_caller_identity" "current" {}

module "mut_guardduty" {
  source = "../../../../modules//guardduty"
  is_organization_gd         = true
  trusted_iam_kms_admin_arns = [data.aws_caller_identity.current.id]
}