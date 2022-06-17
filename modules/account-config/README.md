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
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | github.com/marshall7m/terraform-aws-kms | v0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_config_config_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_service_linked_role.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_uuid.bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_caller_identity.cfg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_key_prefix"></a> [bucket\_key\_prefix](#input\_bucket\_key\_prefix) | Prefix for AWS S3 bucket used to store AWS Config logs | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | AWS S3 bucket used to store AWS Config logs | `string` | `null` | no |
| <a name="input_delivery_frequency"></a> [delivery\_frequency](#input\_delivery\_frequency) | Frequency for AWS Config to deliver configuration snapshots | `string` | `"Six_Hours"` | no |
| <a name="input_enable_recorder"></a> [enable\_recorder](#input\_enable\_recorder) | Determines if the AWS Config recorder is active for the account | `bool` | `true` | no |
| <a name="input_include_global_resource_types"></a> [include\_global\_resource\_types](#input\_include\_global\_resource\_types) | Determines if AWS Config is region agnostic for recorded resources | `bool` | `true` | no |
| <a name="input_kms_key_trusted_admin_arns"></a> [kms\_key\_trusted\_admin\_arns](#input\_kms\_key\_trusted\_admin\_arns) | Trusted ARNs that will have administrative permissions for AWS KMS CMK | `list(string)` | `[]` | no |
| <a name="input_logs_arn"></a> [logs\_arn](#input\_logs\_arn) | ARN of the account to create the AWS S3 bucket and KMS CMK. If not specified, defaults to primary provider. | `string` | `null` | no |
| <a name="input_maximum_execution_frequency"></a> [maximum\_execution\_frequency](#input\_maximum\_execution\_frequency) | Default maximum frequency that AWS config evaluates rules | `string` | `"TwentyFour_Hours"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of AWS Config | `string` | `"account-config"` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | List of custom or AWS managed rules to apply to provider's account | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    input_parameters            = optional(string)<br>    source                      = string<br>    source_identifier           = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
