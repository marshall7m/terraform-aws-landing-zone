terraform {
  required_version = ">= 0.15.0"
}

variable "ct_id" {
  description = "AWS account ID that will host CloudTrail"
  type        = string
}

variable "s3_id" {
  description = "AWS account ID that will host the S3 bucket and CloudWatch logs for CloudTrail"
  type        = string
}

module "mut_cloudtrail" {
  source = "../../modules//cloudtrail"
  providers = {
    aws.ct = aws.ct
    aws.s3 = aws.s3
  }

  is_organization_trail      = true
  name                       = "mut-cloudtrail-logs"
  log_retention_days         = 1
  trusted_iam_kms_admin_arns = ["arn:aws:iam::${var.ct_id}:root"]
}