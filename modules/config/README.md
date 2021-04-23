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
| aws.logs | >= 2.42 |
| random | 3.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_key\_prefix | Prefix for AWS S3 bucket used to store AWS Config logs | `string` | `null` | no |
| bucket\_name | AWS S3 bucket used to store AWS Config logs | `string` | `null` | no |
| cfg\_delivery\_frequency | Frequency for AWS Config to deliver configuration snapshots | `string` | `"Six_Hours"` | no |
| cfg\_logs\_bucket | Name of AWS S3 bucket used to store AWS config logs | `string` | `null` | no |
| cfg\_logs\_prefix | Prefix to store logs under within S3 bucket | `string` | `null` | no |
| cfg\_name | Name of AWS Config | `string` | `"account-config"` | no |
| cmk\_trusted\_admin\_arns | Trusted ARNs that will have administrative permissions for AWS KMS CMK | `list(string)` | `[]` | no |
| enable\_cfg\_recorder | Determines if the AWS Config recorder is active for the account | `bool` | `true` | no |
| include\_global\_resource\_types | Determines if AWS Config is region agnostic for recorded resources | `bool` | `true` | no |
| logs\_arn | ARN of the account to create the AWS S3 bucket and KMS CMK. If not specified, defaults to primary provider. | `string` | `null` | no |
| maximum\_execution\_frequency | Default maximum frequency that AWS config evaluates rules | `string` | `"TwentyFour_Hours"` | no |
| rules | List of custom or AWS managed rules to apply to provider's account | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    input_parameters            = optional(string)<br>    source                      = string<br>    source_identifier           = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  }))</pre> | `[]` | no |

## Outputs

No output.
