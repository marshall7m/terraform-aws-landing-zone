#TODO: Create provider docs explaining when to provide the same provider

locals {
  bucket_name = coalesce(var.bucket_name, lower("cloudtrail-logs-${random_uuid.ct_bucket.id}"))
  key_prefix  = var.key_prefix != null ? "${var.key_prefix}/" : ""
}

data "aws_caller_identity" "logs" {
  provider = aws.logs
}

data "aws_region" "ct" {
  #provider = aws.ct
}

data "aws_caller_identity" "ct" {
  #provider = aws.ct
}

data "aws_organizations_organization" "this" {
  count = var.is_organization_trail ? 1 : 0
  #provider = aws.ct
}

resource "aws_cloudtrail" "this" {
  #provider                      = aws.ct
  enable_logging                = var.enable_ct
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.this.id
  s3_key_prefix                 = var.key_prefix
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = module.ct_role.role_arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.this.arn}:*"
  is_organization_trail         = var.is_organization_trail
  is_multi_region_trail         = true
  kms_key_id                    = module.cmk.arn
  tags                          = var.ct_tags

  depends_on = [
    aws_s3_bucket.this,
    module.cmk
  ]
}

module "ct_role" {
  # providers = {
  #   aws = aws.ct
  # }
  source           = "github.com/marshall7m/terraform-aws-iam/modules//iam-role"
  role_name        = var.name
  trusted_services = ["cloudtrail.amazonaws.com"]
  custom_role_policy_arns = [
    aws_iam_policy.ct.arn
  ]
}

module "cmk" {
  providers = {
    aws = aws.logs
  }
  source                  = "github.com/marshall7m/terraform-aws-kms/modules//cmk"
  trusted_admin_arns      = var.trusted_iam_kms_admin_arns
  trusted_user_usage_arns = var.trusted_iam_kms_usage_arns

  trusted_service_usage_principals = ["logs.us-west-2.amazonaws.com"]
  #explicitly only allow the cw log group created in this module to access key
  trusted_service_usage_conditions = [
    {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${data.aws_region.ct.name}:${data.aws_caller_identity.ct.id}:log-group:${var.cw_log_group_name}"
      ]
    }
  ]
  statements = concat([
    {
      sid    = "CloudTrailEncryptLogs"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      actions   = ["kms:GenerateDataKey*"]
      resources = ["*"]
      conditions = [
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          # TODO: see if explicit cross-account arns are needed for organization trail
          values = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.ct.id}:trail/*"]
        }
      ]
    },
    {
      sid    = "CloudTrailDescribeAccess"
      effect = "Allow"
      principals = [
        {
          type        = "Service"
          identifiers = ["cloudtrail.amazonaws.com"]
        }
      ]
      actions   = ["kms:DescribeKey"]
      resources = ["*"]
    },
    # {
    #   sid    = "CloudTrailUsage"
    #   effect = "Allow"
    #   actions = [
    #     "kms:Encrypt",
    #     "kms:Decrypt",
    #     "kms:ReEncrypt*",
    #     "kms:GenerateDataKey*",
    #     "kms:DescribeKey"
    #   ]
    #   principals = [
    #     {
    #       type        = "Service"
    #       identifiers = ["cloudtrail.amazonaws.com"]
    #     }
    #   ]
    #   resources = ["*"]
    # },
    {
      sid    = "CreateAliasAccess"
      effect = "Allow"
      principals = [
        {
          type        = "AWS"
          identifiers = ["*"]
        }
      ]
      actions   = ["kms:CreateAlias"]
      resources = ["*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "kms:ViaService"
          values   = ["ec2.us-west-2.amazonaws.com"]
        },
        {
          test     = "StringEquals"
          variable = "kms:CallerAccount"
          values   = [data.aws_caller_identity.logs.id]
        }
      ]
    }],
    length(var.trusted_iam_kms_decrypt_arns) > 0 ? [{
      sid    = "CloudTrailDecryptionAccess"
      effect = "Allow"
      principals = [
        {
          type        = "AWS"
          identifiers = var.trusted_iam_kms_decrypt_arns
        }
      ]
      actions = [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ],
      resources = ["*"]
      # principals can only perform actions if kms encryption context associated with cloudtrail is not null
      conditions = [
        {
          test     = "Null"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values   = ["false"]
        }
      ]
      }
  ] : [])
}

resource "random_uuid" "ct_bucket" {}

resource "aws_s3_bucket" "this" {
  provider      = aws.logs
  bucket        = local.bucket_name
  force_destroy = true
  versioning {
    enabled = true
  }

  policy = data.aws_iam_policy_document.ct_bucket.json
}

data "aws_iam_policy_document" "ct_bucket" {
  provider = aws.logs

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
    sid = "CloudTrailAccountWriteAccess"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.bucket_name}/${local.key_prefix}AWSLogs/${data.aws_caller_identity.ct.id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid = "CloudTrailCrossAccountWriteAccess"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]

    resources = formatlist("arn:aws:s3:::${local.bucket_name}/${local.key_prefix}AWSLogs/%s/*",
      var.is_organization_trail ?
      [data.aws_organizations_organization.this[0].id] :
      setsubtract(var.aws_accounts, [data.aws_caller_identity.ct.id])
    )

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  #provider          = aws.ct
  name              = var.cw_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = module.cmk.arn
}

resource "aws_iam_policy" "ct" {
  #provider = aws.ct
  name   = var.name
  policy = data.aws_iam_policy_document.ct.json
}

data "aws_iam_policy_document" "ct" {
  #provider = aws.ct

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