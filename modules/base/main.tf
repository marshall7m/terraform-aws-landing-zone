data "aws_caller_identity" "master" {}

module "accounts" {
  source = "..//accounts"

  create_organization = var.create_organization
  child_accounts      = var.child_accounts
  policies            = var.account_policies
}

module "cloudtrail" {
  source = "..//cloudtrail"

  # providers = {
  # 		aws.ct = aws
  # 		aws.logs = aws.logs
  # }
  logs_org_role_arn          = module.accounts.logs_org_role_arn
  is_organization_trail      = true
  name                       = var.ct_name
  log_retention_days         = var.ct_log_retention_days
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
}



