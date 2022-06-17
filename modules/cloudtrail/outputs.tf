output "s3_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.this.id
}

output "cw_log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}

output "kms_key_arn" {
  value = module.kms_key.arn
}

output "ct_arn" {
  value = aws_cloudtrail.this.arn
}