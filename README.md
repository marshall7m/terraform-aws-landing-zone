# Terraform AWS Landing Zone


## Modules

`account-config`:
    
    - Applies account-level AWS Config custom or managed rules
    - Creates AWS S3 bucket with KMS encryption to store Config logs

`org-config`:
    
    - Applies organization-level AWS Config custom or managed rules and/or conformance packs
    - Creates AWS Lambda function to host each custom rule
    - Creates AWS S3 bucket with KMS encryption to store Config logs

`accounts`:

    - Creates AWS organization within calling AWS account\
    - Provisions member accounts with a role that a root organization entity can assume for Administrative access to the account
    - Apply organization-level or account-level policies to member accounts

`cloudtrail`:

    - Apply organization-level or account-level CloudTrail services
    - Attaches an IAM role to the CloudTrail service with the necessary permissions
    - Creates AWS S3 bucket with KMS encryption to store CloudTrail logs
    - Allows the user to explicitly define a separate AWS account provider to store the CloudTrail logs. See for an example: `tests/cloudtrail`

`guardduty`:

    - Apply organization-level or account-level Guardduty service
    - Creates AWS S3 bucket with KMS encryption to store Guardduty findings


`base`:

    - Configures all of the organization-level modules mentioned above into one easily definable module
    - Applies default managed AWS Config rules: (all of which should be covered by this module)
        - CLOUD_TRAIL_ENABLED
        - GUARDDUTY_ENABLED_CENTRALIZED
        - CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED
        - ACCOUNT_PART_OF_ORGANIZATIONS
    - Provisions AWS Config and AWS GuardDuty within the AWS account that is labeled as the `is_cfg` account
    - Provisions separate AWS S3 buckets to store AWS Guardduty, Config, and CloudTrail logs within the AWS account that is labeled as the `is_logs` account

# Base Module

## Features
- Accounts: Creates an AWS Organizations with member accounts. See more at `modules/accounts`
- CloudTrail: Provisions AWS CloudTrail at the organization-level hosted via the AWS root account. See more at `modules/cloudtrail`
- GuardDuty: Provisions AWS GuardDuty at the organization-level via the AWS member account labeled as the config account.  See more at `modules/guardduty`
- Config: Provisions AWS Config at the organization-level via the AWS member account labeled as the config account. See more at `modules/org-config`

## Usage

```
module "base" {
  source = "github.com/marshall7m/terraform-aws-landing-zone"
  create_organization = true
  child_accounts = [
    {
      name  = "entrypoint"
      email = "example+entrypoint@gmail.com"
    },
    {
      name  = "shared-services"
      email = "example+shared@gmail.com"
    },
    {
      name  = "dev"
      email = "example+dev@gmail.com"
    },
    {
      name  = "sandbox"
      email = "example+sandbox@gmail.com"
    },
    {
      name  = "logs"
      email = "example+logs@gmail.com"
      is_logs = true
    },
    {
      name  = "cfg"
      email = "example+cfg@gmail.com"
      is_cfg = true
    }
  ]
  enabled_gd = true
  enable_ct = true
  ct_name = "example-org-cloudtrail"
  ct_log_retention_days = 3
  create_gd_s3_bucket = true
  cfg_managed_rules = [
    {
      name = "ct"
      rule_identifier = "CLOUD_TRAIL_ENABLED"
      exclude_root = true
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.41.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_accounts"></a> [accounts](#module\_accounts) | ./modules//accounts | n/a |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ./modules//cloudtrail | n/a |
| <a name="module_guardduty"></a> [guardduty](#module\_guardduty) | ./modules//guardduty | n/a |
| <a name="module_org_cfg"></a> [org\_cfg](#module\_org\_cfg) | ./modules//org-config | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_organization_admin_account.cfg_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_organizations_delegated_administrator.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_organizations_delegated_administrator.config_multi_account_setup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_organizations_delegated_administrator.guardduty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_arn.cfg_org_role_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_caller_identity.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_part_of_org_rule"></a> [account\_part\_of\_org\_rule](#input\_account\_part\_of\_org\_rule) | Configurations for default rule: ACCOUNT\_PART\_OF\_ORGANIZATIONS. Rule checks if <br>member AWS account's organization master account ID is valid | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| <a name="input_account_policies"></a> [account\_policies](#input\_account\_policies) | List of account policies that can be attached to child accounts | <pre>list(object({<br>    name    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| <a name="input_cfg_custom_rules"></a> [cfg\_custom\_rules](#input\_cfg\_custom\_rules) | List of custom or AWS managed rules to apply to provider's account | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    input_parameters            = optional(map(string))<br>    rule_identifier             = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br><br>    function_name = optional(string)<br>    handler       = string<br>    runtime       = string<br>    env_vars      = optional(map(string))<br>    filename      = optional(string)<br>    image_uri     = optional(string)<br>    s3_bucket     = optional(string)<br>    s3_key        = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_cfg_is_active"></a> [cfg\_is\_active](#input\_cfg\_is\_active) | Determines if AWS Config recorder is active in each child account within organization | `bool` | `true` | no |
| <a name="input_cfg_managed_rules"></a> [cfg\_managed\_rules](#input\_cfg\_managed\_rules) | List of AWS managed rules to apply to provider's account | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    input_parameters            = optional(map(string))<br>    rule_identifier             = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_child_accounts"></a> [child\_accounts](#input\_child\_accounts) | List of AWS child accounts and their respective configurations | <pre>list(object({<br>    name                       = string<br>    email                      = string<br>    role_name                  = optional(string)<br>    parent_id                  = optional(string)<br>    policies                   = optional(list(string))<br>    tags                       = optional(map(string))<br>    is_logs                    = optional(bool)<br>    is_cfg                     = optional(bool)<br>    iam_user_access_to_billing = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_create_gd_s3_bucket"></a> [create\_gd\_s3\_bucket](#input\_create\_gd\_s3\_bucket) | Determines if Guard Duty findings should be publised to a S3 bucket within the logs account | `bool` | `true` | no |
| <a name="input_create_organization"></a> [create\_organization](#input\_create\_organization) | Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`) | `bool` | `true` | no |
| <a name="input_ct_cw_logs_enabled_rule"></a> [ct\_cw\_logs\_enabled\_rule](#input\_ct\_cw\_logs\_enabled\_rule) | Configurations for default rule: CLOUD\_TRAIL\_CLOUD\_WATCH\_LOGS\_ENABLED. Rule checks if <br>CloudTrail CloudWatch logs are enabled within AWS Organization's master account | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| <a name="input_ct_enabled_rule"></a> [ct\_enabled\_rule](#input\_ct\_enabled\_rule) | Configurations for default rule: CLOUD\_TRAIL\_ENABLED. Rule checks if Cloudtrail is <br>enabled within each account that's not within <br>`excluded_accounts` attribute" | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| <a name="input_ct_is_active"></a> [ct\_is\_active](#input\_ct\_is\_active) | Determines if Cloudtrail logging is active (only suspends Cloudtrail logging if false) | `bool` | `true` | no |
| <a name="input_ct_log_retention_days"></a> [ct\_log\_retention\_days](#input\_ct\_log\_retention\_days) | Number of days Cloud Watch will retain the logs | `number` | n/a | yes |
| <a name="input_ct_name"></a> [ct\_name](#input\_ct\_name) | Name of CloudTrail | `string` | n/a | yes |
| <a name="input_enable_ct"></a> [enable\_ct](#input\_enable\_ct) | Determines if organization-level Cloudtrail should be used | `bool` | `true` | no |
| <a name="input_enable_gd"></a> [enable\_gd](#input\_enable\_gd) | Determines if organization-level Guard Duty should be used | `bool` | `true` | no |
| <a name="input_gd_bucket_name"></a> [gd\_bucket\_name](#input\_gd\_bucket\_name) | S3 bucket to publish Guard Duty findings to | `string` | `null` | no |
| <a name="input_gd_deny_invalid_crypted_headers"></a> [gd\_deny\_invalid\_crypted\_headers](#input\_gd\_deny\_invalid\_crypted\_headers) | Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uploads with invalid crypted headers | `bool` | `true` | no |
| <a name="input_gd_deny_uncrypted_uploads"></a> [gd\_deny\_uncrypted\_uploads](#input\_gd\_deny\_uncrypted\_uploads) | Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uncrypted uploads | `bool` | `true` | no |
| <a name="input_gd_enabled_centralized_rule"></a> [gd\_enabled\_centralized\_rule](#input\_gd\_enabled\_centralized\_rule) | Configurations for default rule: GUARDDUTY\_ENABLED\_CENTRALIZED. Rule checks if GuardDuty is <br>enabled within the config AWS account ID. Config AWS account can be specified via is\_cfg attribute within `var.child_accounts` | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| <a name="input_gd_is_active"></a> [gd\_is\_active](#input\_gd\_is\_active) | Determines if Guard Duty is active (only suspends Guard Duty activity if false) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_child_accounts"></a> [child\_accounts](#output\_child\_accounts) | Account configurations for AWS member accounts |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO
- Figure out if it's safe to use one CMK for all s3 buckets provisioned via this module
- Give option to consolidate AWS cfg, gd, and ct logging buckets into one?