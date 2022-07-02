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
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource |
| [aws_guardduty_publishing_destination.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_publishing_destination) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_uuid.gd_bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_caller_identity.gd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of S3 bucket for Guard Duty logs | `string` | `null` | no |
| <a name="input_create_gd_s3_bucket"></a> [create\_gd\_s3\_bucket](#input\_create\_gd\_s3\_bucket) | Determines if a S3 bucket should be provisioned for publishing Guard Duty findings | `bool` | `false` | no |
| <a name="input_deny_invalid_crypted_headers"></a> [deny\_invalid\_crypted\_headers](#input\_deny\_invalid\_crypted\_headers) | Determines if S3 bucket policy should deny invalid encryption headers | `bool` | `false` | no |
| <a name="input_deny_uncrypted_uploads"></a> [deny\_uncrypted\_uploads](#input\_deny\_uncrypted\_uploads) | Determines if S3 bucket policy should deny unencrypted uploads | `bool` | `false` | no |
| <a name="input_enable"></a> [enable](#input\_enable) | Determines if AWS Guard Duty should be active. (Suspends existing Guard Duty monitoring if set to false) | `bool` | `true` | no |
| <a name="input_is_organization_gd"></a> [is\_organization\_gd](#input\_is\_organization\_gd) | Determines if organization Guard Duty should be created | `bool` | `false` | no |
| <a name="input_trusted_iam_kms_admin_arns"></a> [trusted\_iam\_kms\_admin\_arns](#input\_trusted\_iam\_kms\_admin\_arns) | ARNs of IAM entities that will have administrative access to CMK key associated with Guard Duty | `list(string)` | n/a | yes |
| <a name="input_trusted_iam_kms_usage_arns"></a> [trusted\_iam\_kms\_usage\_arns](#input\_trusted\_iam\_kms\_usage\_arns) | ARNs of IAM entities that will have the ability decrypt, read, reencrypt, and describe the CMK key | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
