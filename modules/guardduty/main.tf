data "aws_caller_identity" "gd" {}

data "aws_caller_identity" "logs" {
  provider = aws.logs
}

data "aws_region" "logs" {
  provider = aws.logs
}

locals {
  bucket_name = coalesce(var.bucket_name, lower("guardduty-logs-${random_uuid.gd_bucket[0].id}"))
}

resource "random_uuid" "gd_bucket" {
  count = var.bucket_name == null ? 1 : 0
}

resource "aws_guardduty_detector" "this" {
  enable = var.enable
}

resource "aws_guardduty_organization_configuration" "this" {
  count       = var.is_organization_gd ? 1 : 0
  auto_enable = true
  detector_id = aws_guardduty_detector.this.id
}

resource "aws_guardduty_organization_admin_account" "this" {
  count            = var.is_organization_gd != null ? 1 : 0
  admin_account_id = data.aws_caller_identity.gd.id
}

data "aws_iam_policy_document" "s3" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs
  
  statement {
    sid = "GuardDutyWriteAccess"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "GuardDutyReadAccess"
    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "DenyNonHTTPSAccess"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.deny_uncrypted_uploads ? [1] : []
    content {
      sid    = "DenyUnencryptedUploads"
      effect = "Deny"
      principals {
        type        = "Service"
        identifiers = ["guardduty.amazonaws.com"]
      }
      actions   = ["s3:PutObject"]
      resources = ["arn:aws:s3:::${local.bucket_name}/*"]
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption"
        values   = ["aws:kms"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.deny_invalid_crypted_headers ? [1] : []
    content {
      sid    = "DenyInvalidUnencryptedHeaders"
      effect = "Deny"
      principals {
        type        = "Service"
        identifiers = ["guardduty.amazonaws.com"]
      }
      actions   = ["s3:PutObject"]
      resources = ["arn:aws:s3:::${local.bucket_name}/*"]
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
        values   = [module.cmk[0].arn]
      }
    }
  }
}

module "cmk" {
  count = var.create_gd_s3_bucket ? 1 : 0
  providers = {
    aws = aws.logs
  }
  source                  = "github.com/marshall7m/terraform-aws-kms/modules//cmk"
  trusted_admin_arns      = var.trusted_iam_kms_admin_arns
  trusted_user_usage_arns = var.trusted_iam_kms_usage_arns

  statements = [
    {
      sid    = "GuardDutyEncryptAccess"
      effect = "Allow"
      actions = [
        "kms:GenerateDataKey"
      ]

      resources = ["*"]
      principals = [
        {
          type        = "Service"
          identifiers = ["guardduty.amazonaws.com"]
        }
      ]
    }
  ]
}

resource "aws_s3_bucket" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs

  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  policy = data.aws_iam_policy_document.s3[0].json
}

resource "aws_guardduty_publishing_destination" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0

  detector_id     = aws_guardduty_detector.this.id
  destination_arn = aws_s3_bucket.this[0].arn
  kms_key_arn     = module.cmk[0].arn
}