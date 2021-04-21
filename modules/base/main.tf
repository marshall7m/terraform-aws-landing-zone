data "aws_caller_identity" "master" {}

module "accounts" {
  source = "..//accounts"

  create_organization = var.create_organization
  child_accounts      = var.child_accounts
  policies            = var.account_policies
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
}

module "guardduty" {
  source            = "..//guardduty"
  logs_org_role_arn = module.accounts.logs_org_role_arn

  enable                       = var.gd_is_active
  is_organization_gd           = true
  create_gd_s3_bucket          = var.create_gd_s3_bucket
  bucket_name                  = var.gd_bucket_name
  trusted_iam_kms_admin_arns   = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
  deny_uncrypted_uploads       = var.gd_deny_uncrypted_uploads
  deny_invalid_crypted_headers = var.gd_deny_invalid_crypted_headers
}

module "cloudtrail" {
  source            = "..//cloudtrail"
  logs_org_role_arn = module.accounts.logs_org_role_arn

  enable_logging             = var.ct_is_active
  is_organization_trail      = true
  name                       = var.ct_name
  log_retention_days         = var.ct_log_retention_days
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
}

#TODO: Remove generated config module and pass provider via for_each when issue is resolved: https://github.com/hashicorp/terraform/issues/24476
resource "local_file" "per_account_generated" {
  content = templatefile("generate_config_module.tpl", {
    logs_org_role_arn = module.accounts.logs_org_role_arn
    accounts = module.accounts.child_accounts
    trusted_iam_kms_admin_arns = "arn:aws:iam::${data.aws_caller_identity.master.id}:root"
  })
  filename = "generate_config_module.tf"
}

resource "null_resource" "this" {
  provisioner "local-exec" {
    command = "terraform init"
  }
  depends_on = [
    local_file.per_account_generated
  ]
}