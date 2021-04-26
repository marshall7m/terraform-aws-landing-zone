
data "aws_caller_identity" "logs" {
  provider = aws.logs
}
resource "random_uuid" "bucket" {}

resource "aws_s3_bucket" "this" {
  provider      = aws.logs
  bucket        = local.bucket_name
  force_destroy = true
  versioning {
    enabled = true
  }

  policy = data.aws_iam_policy_document.bucket.json
}

data "aws_iam_policy_document" "bucket" {
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
    resources = ["arn:aws:s3:::${local.bucket_name}/${local.bucket_key_prefix}AWSLogs/${data.aws_caller_identity.logs.id}/Config/*"]
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

  trusted_admin_arns = length(var.cmk_trusted_admin_arns) > 0 ? var.cmk_trusted_admin_arns : [var.logs_role_arn]
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