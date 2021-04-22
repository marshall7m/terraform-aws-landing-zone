## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.15.0 |
| aws | >= 2.42 |
| random | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42 |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_policies | List of account policies that can be attached to child accounts | <pre>list(object({<br>    name    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| child\_accounts | List of AWS child accounts and their respective configurations | <pre>list(object({<br>    name                       = string<br>    email                      = string<br>    role_name                  = optional(string)<br>    parent_id                  = optional(string)<br>    policies                   = optional(list(string))<br>    tags                       = optional(map(string))<br>    is_logs                    = optional(bool)<br>    iam_user_access_to_billing = optional(bool)<br>    cfg_active                 = optional(bool)<br>  }))</pre> | `[]` | no |
| create\_gd\_s3\_bucket | Determines if Guard Duty findings should be publised to a S3 bucket within the logs account | `bool` | `true` | no |
| create\_organization | Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`) | `bool` | `true` | no |
| ct\_is\_active | Determines if Cloudtrail logging is active (only suspends Cloudtrail logging if false) | `bool` | `true` | no |
| ct\_log\_retention\_days | Number of days Cloud Watch will retain the logs | `number` | n/a | yes |
| ct\_name | Name of CloudTrail | `string` | n/a | yes |
| enable\_ct | Determines if organization-level Cloudtrail should be used | `bool` | `true` | no |
| enable\_gd | Determines if organization-level Guard Duty should be used | `bool` | `true` | no |
| gd\_bucket\_name | S3 bucket to publish Guard Duty findings to | `string` | `null` | no |
| gd\_deny\_invalid\_crypted\_headers | Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uploads with invalid crypted headers | `bool` | `true` | no |
| gd\_deny\_uncrypted\_uploads | Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uncrypted uploads | `bool` | `true` | no |
| gd\_is\_active | Determines if Guard Duty is active (only suspends Guard Duty activity if false) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| logs\_role\_arn | n/a |
