<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.42 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.42 |
| <a name="provider_aws.logs"></a> [aws.logs](#provider\_aws.logs) | >= 2.42 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ct_role"></a> [ct\_role](#module\_ct\_role) | github.com/marshall7m/terraform-aws-iam//modules/iam-role | v0.1.0 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | github.com/marshall7m/terraform-aws-kms | v0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.ct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_uuid.ct_bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_caller_identity.ct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ct_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.ct](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts"></a> [aws\_accounts](#input\_aws\_accounts) | AWS accounts that will write to the CloudTrail S3 bucket<br><br>Prereqs:<br>  - Module is not used to create organization trail (var.is\_organization\_trail = false)<br>  - Do not turn on CloudTrail in any of the acconts specified yet | `list(string)` | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of S3 bucket for Cloud Trail logs | `string` | `null` | no |
| <a name="input_ct_tags"></a> [ct\_tags](#input\_ct\_tags) | Tags for Cloud Trail | `map(string)` | `{}` | no |
| <a name="input_cw_log_group_name"></a> [cw\_log\_group\_name](#input\_cw\_log\_group\_name) | Name of Cloud Watch log group name | `string` | `"cloudtrail-logs"` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Determines if logging is enabled for Cloud Trail | `bool` | `true` | no |
| <a name="input_include_global_service_events"></a> [include\_global\_service\_events](#input\_include\_global\_service\_events) | Determines if non-regional services like IAM will be logged via Cloud Trail | `bool` | `true` | no |
| <a name="input_is_organization_trail"></a> [is\_organization\_trail](#input\_is\_organization\_trail) | Determines if module should create an organization CloudTrail <br>Prereqs:<br>  - AWS Organization must already exists<br>  - Terraform AWS provider must be configured with organization master account | `bool` | `false` | no |
| <a name="input_key_prefix"></a> [key\_prefix](#input\_key\_prefix) | S3 key prefix to put Cloud Trail logs under | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days Cloud Watch will retain the logs | `number` | n/a | yes |
| <a name="input_logs_arn"></a> [logs\_arn](#input\_logs\_arn) | ARN of the account to create the AWS S3 bucket and KMS CMK. If not specified, defaults to primary provider. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of CloudTrail | `string` | n/a | yes |
| <a name="input_trusted_iam_kms_admin_arns"></a> [trusted\_iam\_kms\_admin\_arns](#input\_trusted\_iam\_kms\_admin\_arns) | ARNs of IAM entities that will have administrative access to CMK key associated with Cloud Trail | `list(string)` | n/a | yes |
| <a name="input_trusted_iam_kms_decrypt_arns"></a> [trusted\_iam\_kms\_decrypt\_arns](#input\_trusted\_iam\_kms\_decrypt\_arns) | ARNs of IAM entities that will have the ability to only decrypt the CMK key via it's associated AWS account's CloudTrail | `list(string)` | `[]` | no |
| <a name="input_trusted_iam_kms_usage_arns"></a> [trusted\_iam\_kms\_usage\_arns](#input\_trusted\_iam\_kms\_usage\_arns) | ARNs of IAM entities that will have the ability decrypt, read, reencrypt, and describe the CMK key | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ct_arn"></a> [ct\_arn](#output\_ct\_arn) | n/a |
| <a name="output_cw_log_group_arn"></a> [cw\_log\_group\_arn](#output\_cw\_log\_group\_arn) | n/a |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO
- Setup CT mode: data event, insights, etc
- add MFA delete
- add MFA delete policy to s3