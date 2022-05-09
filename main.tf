provider "aws" {}
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
  default_managed_rules = [
    merge(
      {
        description     = "Checks if CloudTrail is enabled within each member AWS account"
        rule_identifier = "CLOUD_TRAIL_ENABLED"
        input_parameters = {
          s3BucketName = module.cloudtrail.s3_bucket_name
          #TODO: Add sns for ct
          # snsTopicArn = ""
          cloudWatchLogsLogGroupArn = module.cloudtrail.cw_log_group_arn
        }
      },
      defaults(var.ct_enabled_rule, {
        enable       = true
        name         = "cloudtrail-enabled"
        exclude_root = true
      })
    ),
    merge(
      {
        description     = "Checks if GuardDuty is enabled within config AWS account"
        rule_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
        description     = ""
        input_parameters = {
          CentralMonitoringAccount = data.aws_arn.cfg_org_role_arn.account
        }
      },
      defaults(var.gd_enabled_centralized_rule, {
        enable       = true
        name         = "guardduty-enabled"
        exclude_root = true
      })
    ),
    merge(
      {
        description     = "Checks if CloudTrail CloudWatch logs are enabled within AWS Organization CloudTrail's"
        rule_identifier = "CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED"
      },
      defaults(var.ct_cw_logs_enabled_rule, {
        enable       = true
        name         = "cloudtrail-cloudwatch-log-group-enabled"
        exclude_root = true
      })
    ),
    merge(
      {
        rule_identifier = "ACCOUNT_PART_OF_ORGANIZATIONS"
        description     = "Checks if member AWS account's organization master account ID is valid"
        input_parameters = {
          MasterAccountId = data.aws_caller_identity.master.id
        }
      },
      defaults(var.account_part_of_org_rule, {
        enable       = true
        name         = "account-part-of-organization"
        exclude_root = true
      })
    )
  ]
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
  /*
  used as a workaround to implicitly create a dependency on 
  `aws_guardduty_organization_admin_account` given modules can't use depends_on when
  provider configurations are configured at runtime
  */
  gd_arn = aws_guardduty_organization_admin_account.cfg_account.id != null ? local.cfg_org_role_arn : local.cfg_org_role_arn

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


#TODO: `Add aws_organizations_delegated_adminstrator` when resource is added: https://github.com/hashicorp/terraform-provider-aws/issues/14932

/*
The 3 `null_resource` blocks below will configure the config AWS account as a delegated admin of
AWS Config, Config MultiAccountSetup, and GuardDuty. This is needed in order to provision
these services within the config account. The main purpose of these services being hosted 
within the config account instead of the root account is security. Specifically,
this will reduce the amount of services that will be maintained and monitored via
the root account which will decrease the need to access the root account and the 
likelyhood of the root account being compromised within that process. 
*/

resource "null_resource" "delegate_config" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/files/delegate_admin.sh", {
      # if the calling master account entity is a role then pass the role so the script can assume the role
      master_account_role_arn = split("/", data.aws_caller_identity.master.arn)[0] == "user" ? null : data.aws_caller_identity.master.arn
      account_id              = data.aws_arn.cfg_org_role_arn.account
      principal               = "config.amazonaws.com"
    })
  }
}

resource "null_resource" "delegate_config_multiaccountsetup" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/files/delegate_admin.sh", {
      # if the calling master account entity is a role then pass the role so the script can assume the role
      master_account_role_arn = split("/", data.aws_caller_identity.master.arn)[0] == "user" ? null : data.aws_caller_identity.master.arn
      account_id              = data.aws_arn.cfg_org_role_arn.account
      principal               = "config-multiaccountsetup.amazonaws.com"
    })
  }
  depends_on = [
    null_resource.delegate_config
  ]
}

resource "null_resource" "delegate_guardduty" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/files/delegate_admin.sh", {
      # if the calling master account entity is a role then pass the role so the script can assume the role
      master_account_role_arn = split("/", data.aws_caller_identity.master.arn)[0] == "user" ? null : data.aws_caller_identity.master.arn
      account_id              = data.aws_arn.cfg_org_role_arn.account
      principal               = "guardduty.amazonaws.com"
    })
  }
  depends_on = [
    null_resource.delegate_config_multiaccountsetup
  ]
}

resource "aws_guardduty_organization_admin_account" "cfg_account" {
  admin_account_id = data.aws_arn.cfg_org_role_arn.account
}

module "org_cfg" {
  source = "..//org-config"
  providers = {
    aws.master = aws
  }

  logs_role_arn = local.logs_org_role_arn
  cfg_role_arn  = local.cfg_org_role_arn

  managed_rules = [for rule in concat(local.cfg_managed_rules,
    [for default_rule in local.default_managed_rules : default_rule.enable ? default_rule : null]) :
    merge(rule, {
      excluded_accounts = concat(rule.exclude_root ? [data.aws_caller_identity.master.id] : [], [for name in rule.excluded_accounts : module.accounts.child_accounts[name].id])
    })
  ]
  custom_rules = [for rule in local.cfg_custom_rules :
    merge(rule, {
      excluded_accounts = concat(rule.exclude_root ? [data.aws_caller_identity.master.id] : [], [for name in rule.excluded_accounts : module.accounts.child_accounts[name].id])
    })
  ]
}