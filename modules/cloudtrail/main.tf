#TODO: Create provider docs explaining when to provide the same provider

# Provider to provision CloudTrail in
# provider "aws" {
#   alias = "ct"
# }

# provider "aws" {
#   alias = "s3"
# }

# provider "random" {}

locals {
  bucket_name = coalesce(var.bucket_name, lower("cloudtrail-logs-${random_id.ct_s3.id}"))
  key_prefix = var.key_prefix != null ? "${var.key_prefix}/" : ""
}

data "aws_caller_identity" "s3" {
  provider = aws.s3
}

data "aws_region" "s3" {
  provider = aws.s3
}

data "aws_caller_identity" "ct" {
  provider = aws.ct
}

data "aws_organizations_organization" "this" {
  count = var.is_organization_trail ? 1 : 0
  provider = aws.ct
}

resource "aws_cloudtrail" "this" {
  provider                      = aws.ct
  enable_logging                = var.enable_ct
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.this.id
  s3_key_prefix = var.key_prefix
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = module.ct_role.role_arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.this.arn}:*"
  is_organization_trail         = var.is_organization_trail
  is_multi_region_trail         = true
  kms_key_id                    = module.cmk.arn
  tags                          = var.ct_tags
}

module "ct_role" {
  providers = {
    aws = aws.ct
  }
  source           = "github.com/marshall7m/terraform-aws-iam/modules//iam-role"
  role_name        = var.name
  trusted_services = ["cloudtrail.amazonaws.com"]
  custom_role_policy_arns = [
    aws_iam_policy.ct_cw.arn
  ]
}

module "cmk" {
  providers = {
    aws = aws.s3
  }
  source             = "github.com/marshall7m/terraform-aws-kms/modules//cmk"
  account_id         = tostring(data.aws_caller_identity.ct.id)
  trusted_admin_arns = var.trusted_kms_admin_arns
  # trusted_user_usage_arns = var.trusted_kms_user_usage_arns
  
  trusted_service_usage_principals = ["logs.us-west-2.amazonaws.com"]
  #explicitly only allow the cw log group created in this module to access key
  trusted_service_usage_conditions = [
    {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${data.aws_region.s3.name}:${data.aws_caller_identity.s3.id}:log-group:${var.cw_log_group_name}"
      ]
    }
  ]
  statements = concat([
    {
      sid = "CloudTrailEncryptLogs"
      effect = "Allow"
      principals = [
        {
          type = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      actions = ["kms:GenerateDataKey*"]
      resources = ["*"]
      conditions = [
        {
          test = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.s3.id}:trail/*"]
        }
      ]
    }, 
    {
      sid = "CloudTrailDescribeAccess"
      effect = "Allow"
      principals = [
        {
          type = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      actions = ["kms:DescribeKey"]
      resources = ["*"]
    }],
    length(var.trusted_kms_user_usage_arns) > 0 ? [{
      sid = "CloudTrailCrossAccountDecryption"
      effect = "Allow",
      principals = [
        {
          type = "AWS"
          identifiers = var.trusted_kms_user_usage_arns
        }
      ]
      actions = [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      resources = ["*"]
      conditions = [
        # {
        #   test = "StringEquals"
        #   variable = "kms:CallerAccount"
        #   values = var.aws_accounts
        # },
        {
          test = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.ct.id}:trail/*"]
        }
      ] 
    }
  ] : [])
}

resource "random_id" "ct_s3" {
  byte_length = 8
}

resource "aws_s3_bucket" "this" {
  provider      = aws.s3
  bucket        = local.bucket_name
  force_destroy = true

  policy = data.aws_iam_policy_document.ct_s3.json
}

data "aws_iam_policy_document" "ct_s3" {
  provider = aws.s3

  statement {
    sid = "CloudTrailAclCheckAccess"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.bucket_name}"]
  }

  statement {
    sid = "CloudTrailWriteAccess"
    principals {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
    actions = ["s3:PutObject"]

    resources = formatlist("arn:aws:s3:::${local.bucket_name}/${local.key_prefix}AWSLogs/%s/*",
      var.is_organization_trail ?
      [data.aws_organizations_organization.this[0].id] :
      distinct(concat(var.aws_accounts, [data.aws_caller_identity.ct.id]))
    )

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  provider          = aws.s3
  name              = var.cw_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = module.cmk.arn
}

resource "aws_iam_policy" "ct_cw" {
  provider = aws.ct
  name     = "cloudtrail-${var.name}-cw-access"
  policy   = data.aws_iam_policy_document.ct_cw.json
}

data "aws_iam_policy_document" "ct_cw" {
  provider = aws.s3

  statement {
    sid = "CloudTrailCreateStreamAccess"

    actions = ["logs:CreateLogStream"]
    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*"
    ]
  }

  statement {
    sid = "CloudTrailPutEventAccess"

    actions = ["logs:PutLogEvents"]
    resources = [
      "${aws_cloudwatch_log_group.this.arn}:*"
    ]
  }
}