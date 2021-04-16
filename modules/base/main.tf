data "aws_caller_identity" "master" {}

module "accounts" {
  source = "..//accounts"

  create_organization = var.create_organization
  child_accounts      = var.child_accounts
  policies            = var.account_policies
}

module "guardduty" {
  count  = var.enable_gd ? 1 : 0
  source = "..//guardduty"

  enable                       = var.gd_is_active
  is_organization_gd           = true
  create_gd_s3_bucket          = var.create_gd_s3_bucket
  bucket_name                  = var.gd_bucket_name
  trusted_iam_kms_admin_arns   = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
  deny_uncrypted_uploads       = var.gd_deny_uncrypted_uploads
  deny_invalid_crypted_headers = var.gd_deny_invalid_crypted_headers
}

module "cloudtrail" {
  count  = var.enable_ct ? 1 : 0
  source = "..//cloudtrail"

  # providers = {
  # 		aws.ct = aws
  # 		aws.logs = aws.logs
  # }
  enable_logging             = var.ct_is_active
  logs_org_role_arn          = module.accounts.logs_org_role_arn
  is_organization_trail      = true
  name                       = var.ct_name
  log_retention_days         = var.ct_log_retention_days
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
}



