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

resource "aws_guardduty_detector" "this" {
  enable = var.enable
}

resource "aws_guardduty_organization_configuration" "this" {
  count       = var.is_organization_gd ? 1 : 0
  auto_enable = true
  detector_id = aws_guardduty_detector.this.id
}

resource "aws_guardduty_publishing_destination" "this" {
  count = var.create_gd_s3_bucket ? 1 : 0

  detector_id     = aws_guardduty_detector.this.id
  destination_arn = aws_s3_bucket.this[0].arn
  kms_key_arn     = module.kms_key[0].arn
}

#tfsec:ignore:AWS002
resource "aws_s3_bucket" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs

  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs

  bucket = aws_s3_bucket.this[0].id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs
  bucket   = aws_s3_bucket.this[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs
  bucket   = aws_s3_bucket.this[0].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = module.kms_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count    = var.create_gd_s3_bucket ? 1 : 0
  provider = aws.logs
  bucket   = aws_s3_bucket.this[0].id
  policy   = data.aws_iam_policy_document.s3[0].json
}

resource "random_uuid" "gd_bucket" {
  count = var.bucket_name == null ? 1 : 0
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
        values   = [module.kms_key[0].arn]
      }
    }
  }
}

module "kms_key" {
  source = "github.com/marshall7m/terraform-aws-kms?ref=v0.1.0"

  count = var.create_gd_s3_bucket ? 1 : 0
  providers = {
    aws = aws.logs
  }
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