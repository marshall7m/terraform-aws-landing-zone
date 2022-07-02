
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.42 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.42 |
| <a name="provider_aws.logs"></a> [aws.logs](#provider\_aws.logs) | >= 2.42 |
| <a name="provider_aws.master"></a> [aws.master](#provider\_aws.master) | >= 2.42 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aggregator_role"></a> [aggregator\_role](#module\_aggregator\_role) | github.com/marshall7m/terraform-aws-iam//modules/iam-role | v0.1.0 |
| <a name="module_cfg_recorder_role"></a> [cfg\_recorder\_role](#module\_cfg\_recorder\_role) | github.com/marshall7m/terraform-aws-iam//modules/iam-role | v0.1.0 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | github.com/marshall7m/terraform-aws-kms | v0.1.0 |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | github.com/marshall7m/terraform-aws-lambda | v0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_config_configuration_aggregator.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_aggregator) | resource |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_conformance_pack.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_conformance_pack) | resource |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_config_organization_custom_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_organization_custom_rule) | resource |
| [aws_config_organization_managed_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_organization_managed_rule) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [random_uuid.bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_caller_identity.cfg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_caller_identity.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aggregator_name"></a> [aggregator\_name](#input\_aggregator\_name) | Name for AWS Config aggregator | `string` | `null` | no |
| <a name="input_bucket_key_prefix"></a> [bucket\_key\_prefix](#input\_bucket\_key\_prefix) | Prefix for AWS S3 bucket used to store AWS Config logs | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | AWS S3 bucket used to store AWS Config logs | `string` | `null` | no |
| <a name="input_conformance_packs"></a> [conformance\_packs](#input\_conformance\_packs) | List of conformance packs to apply to AWS Organization accounts | <pre>list(object({<br>    name = string<br>    inputs_parameters = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>    template_body   = optional(string)<br>    template_s3_uri = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_custom_rules"></a> [custom\_rules](#input\_custom\_rules) | List of custom rules to apply to specified organization accounts | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    input_parameters            = optional(map(string))<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br><br>    function_name = optional(string)<br>    handler       = string<br>    runtime       = string<br>    env_vars      = optional(map(string))<br>    filename      = optional(string)<br>    image_uri     = optional(string)<br>    s3_bucket     = optional(string)<br>    s3_key        = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_delivery_channel_name"></a> [delivery\_channel\_name](#input\_delivery\_channel\_name) | Name for AWS Config delivery channel | `string` | `null` | no |
| <a name="input_delivery_frequency"></a> [delivery\_frequency](#input\_delivery\_frequency) | Frequency for AWS Config to deliver configuration snapshots | `string` | `"Six_Hours"` | no |
| <a name="input_enable_recorder"></a> [enable\_recorder](#input\_enable\_recorder) | Determines if the AWS Config recorder is active for the account | `bool` | `true` | no |
| <a name="input_include_global_resource_types"></a> [include\_global\_resource\_types](#input\_include\_global\_resource\_types) | Determines if AWS Config is region agnostic for recorded resources | `bool` | `true` | no |
| <a name="input_kms_key_trusted_admin_arns"></a> [kms\_key\_trusted\_admin\_arns](#input\_kms\_key\_trusted\_admin\_arns) | Trusted ARNs that will have administrative permissions for AWS KMS CMK | `list(string)` | `[]` | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of AWS managed rules to apply to specified organization accounts | <pre>list(object({<br>    name                        = string<br>    description                 = optional(string)<br>    excluded_accounts           = optional(list(string))<br>    input_parameters            = optional(map(string))<br>    rule_identifier             = string<br>    maximum_execution_frequency = optional(string)<br>    tags                        = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_recorder_name"></a> [recorder\_name](#input\_recorder\_name) | Name for AWS Config recorder | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
