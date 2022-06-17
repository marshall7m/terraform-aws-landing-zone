<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| aws | >= 2.42 |
| random | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42 |
| aws.logs | >= 2.42 |
| random | >=3.1.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_accounts | AWS accounts that will write to the CloudTrail S3 bucket<br><br>Prereqs:<br>  - Module is not used to create organization trail (var.is\_organization\_trail = false)<br>  - Do not turn on CloudTrail in any of the acconts specified yet | `list(string)` | `[]` | no |
| bucket\_name | Name of S3 bucket for Cloud Trail logs | `string` | `null` | no |
| ct\_tags | Tags for Cloud Trail | `map(string)` | `{}` | no |
| cw\_log\_group\_name | Name of Cloud Watch log group name | `string` | `"cloudtrail-logs"` | no |
| enable\_logging | Determines if logging is enabled for Cloud Trail | `bool` | `true` | no |
| include\_global\_service\_events | Determines if non-regional services like IAM will be logged via Cloud Trail | `bool` | `true` | no |
| is\_organization\_trail | Determines if module should create an organization CloudTrail <br>Prereqs:<br>  - AWS Organization must already exists<br>  - Terraform AWS provider must be configured with organization master account | `bool` | `false` | no |
| key\_prefix | S3 key prefix to put Cloud Trail logs under | `string` | `null` | no |
| log\_retention\_days | Number of days Cloud Watch will retain the logs | `number` | n/a | yes |
| logs\_arn | ARN of the account to create the AWS S3 bucket and KMS CMK. If not specified, defaults to primary provider. | `string` | `null` | no |
| name | Name of CloudTrail | `string` | n/a | yes |
| trusted\_iam\_kms\_admin\_arns | ARNs of IAM entities that will have administrative access to CMK key associated with Cloud Trail | `list(string)` | n/a | yes |
| trusted\_iam\_kms\_decrypt\_arns | ARNs of IAM entities that will have the ability to only decrypt the CMK key via it's associated AWS account's CloudTrail | `list(string)` | `[]` | no |
| trusted\_iam\_kms\_usage\_arns | ARNs of IAM entities that will have the ability decrypt, read, reencrypt, and describe the CMK key | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| ct\_arn | n/a |
| cw\_log\_group\_arn | n/a |
| kms\_key\_arn | n/a |
| s3\_bucket\_arn | n/a |
| s3\_bucket\_name | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO
- Setup CT mode: data event, insights, etc
- add MFA delete
- add MFA delete policy to s3