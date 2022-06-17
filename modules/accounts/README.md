
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.22 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.22 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_service_access_principals"></a> [aws\_service\_access\_principals](#input\_aws\_service\_access\_principals) | AWS service principals to integrate into AWS organization | `list(string)` | `[]` | no |
| <a name="input_child_accounts"></a> [child\_accounts](#input\_child\_accounts) | List of AWS child accounts and their respective configurations | <pre>list(object({<br>    name                       = string<br>    email                      = string<br>    role_name                  = optional(string)<br>    parent_id                  = optional(string)<br>    policies                   = optional(list(string))<br>    tags                       = optional(map(string))<br>    iam_user_access_to_billing = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_create_organization"></a> [create\_organization](#input\_create\_organization) | Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`) | `bool` | `true` | no |
| <a name="input_feature_set"></a> [feature\_set](#input\_feature\_set) | If `ALL` is used, the AWS organization will integrate all AWS management features. If <br>`CONSOLIDATED_BILLING` is used, the AWS organization will integrate basic AWS management features.<br>See for more info: https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_support-all-features.html | `string` | `"ALL"` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | List of account policies that can be attached to child accounts | <pre>list(object({<br>    name    = string<br>    content = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_child_accounts"></a> [child\_accounts](#output\_child\_accounts) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
