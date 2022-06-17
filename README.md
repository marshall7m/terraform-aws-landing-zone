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
| terraform | >= 1.0.0 |
| aws | >= 3.41.0 |
| random | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.41.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_part\_of\_org\_rule | Configurations for default rule: ACCOUNT\_PART\_OF\_ORGANIZATIONS. Rule checks if <br>member AWS account's organization master account ID is valid | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| account\_policies | List of account policies that can be attached to child accounts | <pre>list(object({<br>    name    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| cfg\_custom\_rules | List of custom or AWS managed rules to apply to provider's account | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    input_parameters            = optional(map(string))<br>    rule_identifier             = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br><br>    function_name = optional(string)<br>    handler       = string<br>    runtime       = string<br>    env_vars      = optional(map(string))<br>    filename      = optional(string)<br>    image_uri     = optional(string)<br>    s3_bucket     = optional(string)<br>    s3_key        = optional(string)<br>  }))</pre> | `[]` | no |
| cfg\_is\_active | Determines if AWS Config recorder is active in each child account within organization | `bool` | `true` | no |
| cfg\_managed\_rules | List of AWS managed rules to apply to provider's account | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    input_parameters            = optional(map(string))<br>    rule_identifier             = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  }))</pre> | `[]` | no |
| child\_accounts | List of AWS child accounts and their respective configurations | <pre>list(object({<br>    name                       = string<br>    email                      = string<br>    role_name                  = optional(string)<br>    parent_id                  = optional(string)<br>    policies                   = optional(list(string))<br>    tags                       = optional(map(string))<br>    is_logs                    = optional(bool)<br>    is_cfg                     = optional(bool)<br>    iam_user_access_to_billing = optional(bool)<br>  }))</pre> | `[]` | no |
| create\_gd\_s3\_bucket | Determines if Guard Duty findings should be publised to a S3 bucket within the logs account | `bool` | `true` | no |
| create\_organization | Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`) | `bool` | `true` | no |
| ct\_cw\_logs\_enabled\_rule | Configurations for default rule: CLOUD\_TRAIL\_CLOUD\_WATCH\_LOGS\_ENABLED. Rule checks if <br>CloudTrail CloudWatch logs are enabled within AWS Organization's master account | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| ct\_enabled\_rule | Configurations for default rule: CLOUD\_TRAIL\_ENABLED. Rule checks if Cloudtrail is <br>enabled within each account that's not within <br>`excluded_accounts` attribute" | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| ct\_is\_active | Determines if Cloudtrail logging is active (only suspends Cloudtrail logging if false) | `bool` | `true` | no |
| ct\_log\_retention\_days | Number of days Cloud Watch will retain the logs | `number` | n/a | yes |
| ct\_name | Name of CloudTrail | `string` | n/a | yes |
| enable\_ct | Determines if organization-level Cloudtrail should be used | `bool` | `true` | no |
| enable\_gd | Determines if organization-level Guard Duty should be used | `bool` | `true` | no |
| gd\_bucket\_name | S3 bucket to publish Guard Duty findings to | `string` | `null` | no |
| gd\_deny\_invalid\_crypted\_headers | Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uploads with invalid crypted headers | `bool` | `true` | no |
| gd\_deny\_uncrypted\_uploads | Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uncrypted uploads | `bool` | `true` | no |
| gd\_enabled\_centralized\_rule | Configurations for default rule: GUARDDUTY\_ENABLED\_CENTRALIZED. Rule checks if GuardDuty is <br>enabled within the config AWS account ID. Config AWS account can be specified via is\_cfg attribute within `var.child_accounts` | <pre>object({<br>    enable                      = optional(bool)<br>    name                        = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    exclude_root                = optional(bool)<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  })</pre> | `{}` | no |
| gd\_is\_active | Determines if Guard Duty is active (only suspends Guard Duty activity if false) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| child\_accounts | Account configurations for AWS member accounts |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO
- Figure out if it's safe to use one CMK for all s3 buckets provisioned via this module
- Give option to consolidate AWS cfg, gd, and ct logging buckets into one?