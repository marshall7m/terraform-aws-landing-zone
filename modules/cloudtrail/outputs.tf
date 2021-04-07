output "s3_bucket_arn" {
    value = aws_s3_bucket.this.arn
}

output "cw_log_group_arn" {
    value = aws_cloudwatch_log_group.arn
}

output "kms_cmk" {
    value = module.cmk.arn
}

output "ct_arn" {
    value = aws_cloudtrail.this.arn
}