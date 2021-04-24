variable "logs_arn" {
  description = "ARN of the account to create the AWS S3 bucket and KMS CMK. If not specified, defaults to primary provider."
  type        = string
  default     = null
}

variable "enable" {
  description = "Determines if AWS Guard Duty should be active. (Suspends existing Guard Duty monitoring if set to false)"
  type        = bool
  default     = true
}

variable "is_organization_gd" {
  description = "Determines if organization Guard Duty should be created"
  type        = bool
  default     = false
}

variable "create_gd_s3_bucket" {
  description = "Determines if a S3 bucket should be provisioned for publishing Guard Duty findings"
  type        = bool
  default     = false
}

variable "bucket_name" {
  description = "Name of S3 bucket for Guard Duty logs"
  type        = string
  default     = null
}

variable "trusted_iam_kms_admin_arns" {
  description = "ARNs of IAM entities that will have administrative access to CMK key associated with Guard Duty"
  type        = list(string)
}

variable "trusted_iam_kms_usage_arns" {
  description = "ARNs of IAM entities that will have the ability decrypt, read, reencrypt, and describe the CMK key"
  type        = list(string)
  default     = []
}

variable "deny_uncrypted_uploads" {
  description = "Determines if S3 bucket policy should deny unencrypted uploads"
  type        = bool
  default     = false
}

variable "deny_invalid_crypted_headers" {
  description = "Determines if S3 bucket policy should deny invalid encryption headers"
  type        = bool
  default     = false
}