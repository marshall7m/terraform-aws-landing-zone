output "s3_bucket_arn" {
  value = try(aws_s3_bucket.this[0].arn, null)
}

output "kms_key_arn" {
  value = try(module.kms_key[0].arn, null)
}