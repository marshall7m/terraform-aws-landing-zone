data "aws_caller_identity" "current" {}

module "mut_guardduty" {
  source = "../../../../modules//guardduty"
  providers = {
    aws.gd = aws
    aws.s3 = aws
  }
  is_organization_gd         = true
  trusted_iam_kms_admin_arns = [data.aws_caller_identity.current.id]
}