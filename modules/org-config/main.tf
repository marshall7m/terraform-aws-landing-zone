data "aws_caller_identity" "cfg" {}

data "aws_organizations_organization" "this" {
  provider = aws.master
}

locals {
  org_id          = data.aws_organizations_organization.this.id
  aggregator_name = coalesce(var.aggregator_name, "${local.org_id}-delegated-admin-aggregator")
  recorder_name   = coalesce(var.recorder_name, "${local.org_id}-cfg-recorder")

  bucket_name       = coalesce(var.bucket_name, lower("config-logs-${random_uuid.bucket.id}"))
  bucket_key_prefix = var.bucket_key_prefix != null ? "${var.bucket_key_prefix}/" : ""
}

module "aggregator_role" {
  source                  = "github.com/marshall7m/terraform-aws-iam//modules/iam-role?ref=v0.1.0"
  role_name               = local.aggregator_name
  trusted_services        = ["config.amazonaws.com"]
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"]
}

resource "aws_config_configuration_aggregator" "this" {
  name = local.aggregator_name

  organization_aggregation_source {
    all_regions = true
    role_arn    = module.aggregator_role.role_arn
  }
}

resource "aws_config_delivery_channel" "this" {
  count = var.enable_recorder ? 1 : 0

  name           = coalesce(var.delivery_channel_name, "${local.org_id}-cfg-delivery-channel")
  s3_bucket_name = aws_s3_bucket.this.id
  s3_key_prefix  = local.bucket_key_prefix
  #TODO: add SNS
  # sns_topic_arn  = var.sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

module "cfg_recorder_role" {
  source    = "github.com/marshall7m/terraform-aws-iam//modules/iam-role?ref=v0.1.0"
  role_name = local.recorder_name

  trusted_services        = ["config.amazonaws.com"]
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"]
  statements = [
    {
      effect = "Allow"
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
      resources = ["arn:aws:s3:::${local.bucket_name}/${local.bucket_key_prefix}AWSLogs/${data.aws_caller_identity.logs.id}/*"]
      conditions = [
        {
          test     = "StringLike"
          variable = "s3:x-amz-acl"
          values = [
            "bucket-owner-full-control"
          ]
        }
      ]
    },
    {
      effect    = "Allow"
      actions   = ["s3:GetBucketAcl"]
      resources = ["arn:aws:s3:::${local.bucket_name}"]
    },
    {
      sid    = "AWSKMSAccess"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["config.amazonaws.com"]
        }
      ]
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      resources = [module.kms_key.arn]
    },
    {
      effect    = "Allow"
      actions   = ["sns:Publish"]
      resources = ["*"]
    }
  ]
}

resource "aws_config_configuration_recorder" "this" {
  count = var.enable_recorder ? 1 : 0

  name     = local.recorder_name
  role_arn = module.cfg_recorder_role.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_recorder ? 1 : 0

  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

/* 
Need to explicitly create AWS Config recorder within master organization account
to enable rules within master account
*/
# resource "aws_iam_service_linked_role" "master" {
#   provider         = aws.master
#   aws_service_name = "config.amazonaws.com"
# }

# resource "aws_config_configuration_recorder" "master" {
#   count    = var.enable_recorder ? 1 : 0
#   provider = aws.master

#   name     = coalesce(var.recorder_name, "${local.org_id}-cfg-recorder")
#   role_arn = aws_iam_service_linked_role.master.arn

#   recording_group {
#     all_supported                 = true
#     include_global_resource_types = var.include_global_resource_types
#   }
# }