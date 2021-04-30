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
| bucket\_name | Name of S3 bucket for Guard Duty logs | `string` | `null` | no |
| create\_gd\_s3\_bucket | Determines if a S3 bucket should be provisioned for publishing Guard Duty findings | `bool` | `false` | no |
| deny\_invalid\_crypted\_headers | Determines if S3 bucket policy should deny invalid encryption headers | `bool` | `false` | no |
| deny\_uncrypted\_uploads | Determines if S3 bucket policy should deny unencrypted uploads | `bool` | `false` | no |
| enable | Determines if AWS Guard Duty should be active. (Suspends existing Guard Duty monitoring if set to false) | `bool` | `true` | no |
| gd\_arn | IAM role ARN the primary provider will assume to create the AWS GuardDuty resources within its respective account. If not specified, defaults to the aws caller. | `string` | `null` | no |
| is\_organization\_gd | Determines if organization Guard Duty should be created | `bool` | `false` | no |
| logs\_arn | IAM role ARN the `aws.logs` provider will assume to create the AWS S3 bucket and KMS CMK used to store GuardDuty findings. If not specified, defaults to the aws caller. | `string` | `null` | no |
| trusted\_iam\_kms\_admin\_arns | ARNs of IAM entities that will have administrative access to CMK key associated with Guard Duty | `list(string)` | n/a | yes |
| trusted\_iam\_kms\_usage\_arns | ARNs of IAM entities that will have the ability decrypt, read, reencrypt, and describe the CMK key | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cmk\_arn | n/a |
| s3\_bucket\_arn | n/a |
