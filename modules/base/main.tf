data "aws_caller_identity" "master" {}

locals {
  child_accounts = [for account in var.child_accounts : defaults(account, {
    is_logs = false
    is_cfg  = false
  })]
  logs_org_role_arn = one([for account in local.child_accounts :
  module.accounts.child_accounts[account.name].role_arn if account.is_logs])
  cfg_org_role_arn = one([for account in local.child_accounts :
  module.accounts.child_accounts[account.name].role_arn if account.is_cfg])
  cfg_managed_rules = [for rule in var.cfg_managed_rules : defaults(rule, {
    exclude_root = false
  })]
  cfg_custom_rules = [for rule in var.cfg_custom_rules : defaults(rule, {
    exclude_root = false
  })]
}

data "aws_arn" "cfg_org_role_arn" {
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
  source   = "..//guardduty"
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
  source   = "..//cloudtrail"
  logs_arn = local.logs_org_role_arn

  enable_logging             = var.ct_is_active
  is_organization_trail      = true
  name                       = var.ct_name
  log_retention_days         = var.ct_log_retention_days
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${data.aws_caller_identity.master.id}:root"]
}

/* TODO: Create `list delegated admin` null_resource to get current delegated admin services
and use for conditionally triggering daisy chain null_resource register
*/

#TODO: `Add aws_organizations_delegated_adminstrator` when resource is added: https://github.com/hashicorp/terraform-provider-aws/issues/14932
resource "null_resource" "cfg_admin_cfg_principal" {
  count = local.cfg_org_role_arn != null ? 1 : 0
  provisioner "local-exec" {
    command = "aws organizations register-delegated-administrator --service-principal=config.amazonaws.com --account-id=${data.aws_arn.cfg_org_role_arn.account}"
  }
}

resource "null_resource" "cfg_admin_multi_account_cfg_principal" {
  count = local.cfg_org_role_arn != null ? 1 : 0
  provisioner "local-exec" {
    command = "aws organizations register-delegated-administrator --service-principal=config-multiaccountsetup.amazonaws.com --account-id=${data.aws_arn.cfg_org_role_arn.account}"
  }
  depends_on = [
    null_resource.cfg_admin_cfg_principal
  ]
}

resource "null_resource" "cfg_admin_gd_principal" {
  count = local.cfg_org_role_arn != null ? 1 : 0
  provisioner "local-exec" {
    command = "aws organizations register-delegated-administrator --service-principal=guardduty.amazonaws.com --account-id=${data.aws_arn.cfg_org_role_arn.account}"
  }
  depends_on = [
    null_resource.cfg_admin_multi_account_cfg_principal
  ]
}

module "org_cfg" {
  source = "..//org-config"
  providers = {
    aws.master = aws
  }

  logs_role_arn = local.logs_org_role_arn
  cfg_role_arn  = local.cfg_org_role_arn

  managed_rules = [for rule in local.cfg_managed_rules :
    merge(rule, {
      excluded_accounts = concat(rule.exclude_root ? [data.aws_caller_identity.master.id] : [], [for name in rule.excluded_accounts : module.accounts.child_accounts[name].id])
      included_accounts = [for name in rule.included_accounts : module.accounts.child_accounts[name].id]
    })
  ]
  custom_rules = [for rule in local.cfg_custom_rules :
    merge(rule, {
      excluded_accounts = concat(rule.exclude_root ? [data.aws_caller_identity.master.id] : [], [for name in rule.excluded_accounts : module.accounts.child_accounts[name].id])
      included_accounts = [for name in rule.included_accounts : module.accounts.child_accounts[name].id]
    })
  ]
}