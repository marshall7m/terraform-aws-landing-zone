data "aws_caller_identity" "gd" {
  provider = aws.gd
}

data "aws_caller_identity" "s3" {
  provider = aws.s3
}

data "aws_region" "s3" {
  provider = aws.s3
}

locals {
  bucket_name = coalesce(var.bucket_name, lower("guardduty-logs-${random_uuid.gd_bucket.id}"))
}

resource "random_uuid" "gd_bucket" {}

resource "aws_guardduty_detector" "this" {
  provider = aws.gd
  enable   = var.enable
}

resource "aws_guardduty_organization_configuration" "this" {
  count       = var.is_organization_gd ? 1 : 0
  provider    = aws.gd
  auto_enable = true
  detector_id = aws_guardduty_detector.this.id
}

resource "aws_guardduty_organization_admin_account" "this" {
  count            = var.is_organization_gd != null ? 1 : 0
  provider         = aws.gd
  admin_account_id = data.aws_caller_identity.gd.id
}

data "aws_iam_policy_document" "s3" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.s3
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
      resources = "arn:aws:s3:::myBucketName/*"
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption"
        values   = [module.cmk.arn]
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
      resources = "arn:aws:s3:::myBucketName/*"
      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
        values   = [module.cmk.arn]
      }
    }
  }
}

module "cmk" {
  count = var.create_gd_s3_bucket ? 1 : 0
  providers = {
    aws = aws.s3
  }
  source                  = "github.com/marshall7m/terraform-aws-kms/modules//cmk"
  trusted_admin_arns      = var.trusted_iam_kms_admin_arns
  trusted_user_usage_arns = var.trusted_iam_kms_usage_arns

  statements = [
    {
      sid = "GuardDutyEncryptAccess"
			effect = "Allow"
      actions = [
        "kms:GenerateDataKey"
      ]

      resources = [
        "arn:aws:kms:${data.aws_region.s3.name}:${data.aws_caller_identity.s3.account_id}:key/*"
      ]

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
	count = var.create_gd_s3_bucket ? 1 : 0
  provider      = aws.s3
  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  policy = data.aws_iam_policy_document.s3[0].json
}

resource "aws_guardduty_publishing_destination" "this" {
  provider    = aws.gd
  count       = var.create_gd_s3_bucket ? 1 : 0
  detector_id = aws_guardduty_detector.this.id
  destination_arn = aws_s3_bucket.this[0].arn
  kms_key_arn = module.cmk[0].arn
}