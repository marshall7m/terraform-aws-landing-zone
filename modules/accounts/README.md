## Requirements

| Name | Version |
|------|---------|
| terraform | >=0.15.0 |
| aws | >= 3.22 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.22 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_service\_access\_principals | AWS service principals to integrate into AWS organization | `list(string)` | `[]` | no |
| child\_accounts | List of AWS child accounts and their respective configurations | <pre>list(object({<br>    name                       = string<br>    email                      = string<br>    role_name                  = optional(string)<br>    parent_id                  = optional(string)<br>    policies                   = optional(list(string))<br>    tags                       = optional(map(string))<br>    is_logs                    = optional(bool)<br>    iam_user_access_to_billing = optional(bool)<br>  }))</pre> | `[]` | no |
| create\_organization | Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`) | `bool` | `true` | no |
| feature\_set | If `ALL` is used, the AWS organization will integrate all AWS management features. If <br>`CONSOLIDATED_BILLING` is used, the AWS organization will integrate basic AWS management features.<br>See for more info: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_support-all-features.html | `string` | `"ALL"` | no |
| policies | List of account policies that can be attached to child accounts | <pre>list(object({<br>    name    = string<br>    content = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| child\_accounts | n/a |
| logs\_org\_role\_arn | role used for provisioning Cloudtrail S3 bucket and KMS CMK within `..//base` module |
