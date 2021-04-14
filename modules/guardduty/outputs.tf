output "s3_bucket_arn" {
  value = try(aws_s3_bucket.this[0].arn, null)
}

output "cmk_arn" {
  value = try(module.cmk[0].arn, null)
}