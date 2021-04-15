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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account\_policies | List of account policies that can be attached to child accounts | <pre>list(object({<br>    name    = string<br>    content = string<br>  }))</pre> | `[]` | no |
| child\_accounts | List of AWS child accounts and their respective configurations | <pre>list(object({<br>    name                       = string<br>    email                      = string<br>    role_name                  = optional(string)<br>    parent_id                  = optional(string)<br>    policies                   = optional(list(string))<br>    tags                       = optional(map(string))<br>    is_logs                    = optional(bool)<br>    iam_user_access_to_billing = optional(bool)<br>  }))</pre> | `[]` | no |
| create\_organization | Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`) | `bool` | `true` | no |
| ct\_log\_retention\_days | Number of days Cloud Watch will retain the logs | `number` | n/a | yes |
| ct\_name | Name of CloudTrail | `string` | n/a | yes |

## Outputs

No output.
