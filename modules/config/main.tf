data "aws_caller_identity" "cfg" {}

locals {
  bucket_name       = coalesce(var.bucket_name, lower("config-logs-${random_uuid.cfg_bucket.id}"))
  bucket_key_prefix = var.bucket_key_prefix != null ? "${var.bucket_key_prefix}/" : ""
}

resource "aws_config_config_rule" "this" {
  for_each         = { for rule in var.rules : rule.name => rule }
  name             = each.value.name
  description      = each.value.description
  input_parameters = each.value.input_parameters

  source {
    owner             = each.value.source
    source_identifier = each.value.source_identifier
  }

  maximum_execution_frequency = try(each.value.maximum_execution_frequency, var.maximum_execution_frequency)
  tags                        = each.value.tags

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  count = var.enable_cfg_recorder ? 1 : 0

  name       = var.cfg_name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

resource "aws_config_delivery_channel" "this" {
  count = var.enable_cfg_recorder ? 1 : 0

  name           = var.cfg_name
  s3_bucket_name = local.bucket_name
  s3_key_prefix  = local.bucket_key_prefix
  # sns_topic_arn  = var.cfg_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = var.cfg_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "this" {
  count = var.enable_cfg_recorder ? 1 : 0

  name     = var.cfg_name
  role_arn = aws_iam_service_linked_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = var.include_global_resource_types
  }
}

resource "random_uuid" "cfg_bucket" {}

resource "aws_s3_bucket" "this" {
  provider      = aws.logs
  bucket        = local.bucket_name
  force_destroy = true
  versioning {
    enabled = true
  }

  policy = data.aws_iam_policy_document.cfg_bucket.json
}

data "aws_iam_policy_document" "cfg_bucket" {
  provider = aws.logs

  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.bucket_name}"]
  }

  statement {
    sid    = "AWSConfigReadAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]
    resources = ["arn:aws:s3:::${local.bucket_name}"]
  }

  statement {
    sid    = "AWSConfigWriteAccess"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket_name}/${local.bucket_key_prefix}AWSLogs/${data.aws_caller_identity.cfg.id}/Config/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

module "cmk" {
  source = "github.com/marshall7m/terraform-aws-kms/modules//cmk"
  providers = {
    aws = aws.logs
  }

  trusted_admin_arns = length(var.cmk_trusted_admin_arns) > 0 ? var.cmk_trusted_admin_arns : [data.aws_caller_identity.cfg.arn]
  statements = [
    {
      sid    = "AWSConfig"
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
      resources = ["*"]
    }
  ]
}