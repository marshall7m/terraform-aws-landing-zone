provider "aws" {
  alias = "master"
}

provider "aws" {
  alias = "logs"
}

data "aws_caller_identity" "logs" {
  provider = aws.logs
}

data "aws_caller_identity" "master" {
  provider = aws.master
}

data "aws_organizations_organization" "this" {
  provider = aws.master
}


data "aws_region" "logs" {
  provider = aws.logs
}


resource "aws_cloudtrail" "this" {
  provider                      = aws.master
  enable_logging                = var.enable_ct
  name                          = var.name
  s3_bucket_name                = aws_s3_bucket.this.id
  include_global_service_events = var.include_global_service_events
  cloud_watch_logs_role_arn     = module.ct_role.role_arn
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.this.arn}:*"
  is_organization_trail         = true
  is_multi_region_trail         = true
  kms_key_id                    = module.kms.arn
  tags                          = var.ct_tags
}

module "ct_role" {
  providers = {
    aws = aws.master
  }
  source           = "github.com/marshall7m/terraform-aws-iam/modules//iam-role"
  role_name        = var.name
  trusted_services = ["cloudtrail.amazonaws.com"]
  custom_role_policy_arns = [
    aws_iam_policy.ct_cw.arn
  ]
}

module "kms" {
  providers = {
    aws = aws.logs
  }
  source             = "github.com/marshall7m/terraform-aws-kms/modules//cmk"
  account_id         = tostring(data.aws_caller_identity.master.id)
  trusted_admin_arns = var.trusted_kms_admin_arns
  trusted_usage_arns = [module.ct_role.role_arn]
}

resource "aws_s3_bucket" "this" {
  provider      = aws.logs
  bucket        = var.bucket_name
  force_destroy = true

  policy = aws_iam_policy.ct_s3.arn
}

resource "aws_iam_policy" "ct_s3" {
  provider = aws.logs
  name     = "cloudtrail-${var.name}-s3-access"
  policy   = data.aws_iam_policy_document.ct_s3.json
}

data "aws_iam_policy_document" "ct_s3" {
  provider = aws.logs

  statement {
    sid = "CloudTrailAclCheckAccess"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]
  }

  statement {
    sid = "CloudTrailWriteAccess"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["s3:PutObject"]
    resources = formatlist(
      var.key_prefix != null ?
      "arn:aws:s3:::${var.bucket_name}/${var.key_prefix}/AWSLogs/%s/*" :
      "arn:aws:s3:::${var.bucket_name}/AWSLogs/%s/*", data.aws_organizations_organization.this.non_master_accounts[*].id
    )

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_cloudwatch_log_group" "this" {
  provider          = aws.logs
  name              = var.cw_log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = module.kms.arn
}

resource "aws_iam_policy" "ct_cw" {
  provider = aws.master
  name     = "cloudtrail-${var.name}-cw-access"
  policy   = data.aws_iam_policy_document.ct_cw.json
}

data "aws_iam_policy_document" "ct_cw" {
  provider = aws.logs

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