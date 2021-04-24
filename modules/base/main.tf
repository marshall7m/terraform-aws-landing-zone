data "aws_caller_identity" "master" {}

locals {
  child_accounts = [for account in var.child_accounts : defaults(account, {
    is_logs = false
    is_cfg = false
  })]
  logs_org_role_arn = one([for account in local.child_accounts :
  "arn:aws:iam::${module.accounts.child_accounts[account.name].id}:role/${account.role_name}" if account.is_logs])
  cfg_org_role_arn = one([for account in local.child_accounts :
  "arn:aws:iam::${module.accounts.child_accounts[account.name].id}:role/${account.role_name}" if account.is_cfg])
}

data "aws_arn" "cfg_org_role_arn" {
  count = local.cfg_org_role_arn != null ? 1 : 0
  arn = local.cfg_org_role_arn
}

module "accounts" {
  source = "..//accounts"

  create_organization = var.create_organization
  child_accounts      = var.child_accounts
  policies            = var.account_policies
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
}

module "guardduty" {
  source            = "..//guardduty"
  logs_arn = local.logs_org_role_arn

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
  logs_arn = local.logs_org_role_arn

  enable_logging             = var.ct_is_active
  is_organization_trail      = true
  name                       = var.ct_name
  log_retention_days         = var.ct_log_retention_days
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
}

#TODO: Remove generated config module and pass provider via for_each when issue is resolved: https://github.com/hashicorp/terraform/issues/24476
resource "local_file" "per_account_generated" {
  content = templatefile("generate_config_module.tpl", {
    logs_arn          = local.logs_org_role_arn
    accounts                   = module.accounts.child_accounts
    cfg_is_active = var.cfg_is_active
  })
  filename = "generate_config_module.tf"
}

resource "null_resource" "tf_init_generated_modules" {
  provisioner "local-exec" {
    command = "terraform init"
  }
  depends_on = [
    local_file.per_account_generated
  ]
}

#TODO: `Add aws_organizations_delegated_adminstrator` when resource is added: https://github.com/hashicorp/terraform-provider-aws/issues/14932

resource "null_resource" "delegated_org_admin" {
  count = local.cfg_org_role_arn != null ? 1 : 0
	provisioner "local-exec" {
    command = "aws organizations register-delegated-administrator --service-principal=config-multiaccountsetup.amazonaws.com --account-id=${data.aws_arn.cfg_org_role_arn[0].id}"
	}
}

module "org_cfg" {
  source = "..//org-config"
  cfg_role_arn = data.aws_arn.cfg_org_role_arn[0].arn

  managed_rules = var.org_managed_rules
  custom_rules = var.org_custom_rules
}
