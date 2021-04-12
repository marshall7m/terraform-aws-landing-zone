variable "enable_ct" {
  description = "Determines logging is enabled for Cloud Trail"
  type        = bool
  default     = true
}

variable "is_organization_trail" {
  description = <<EOF
Determines if module should create an organization CloudTrail 
Prereqs:
  - AWS Organization must already exists
  - Terraform AWS provider must be configured with organization master account
EOF
  type = bool
  default = false
}

variable "name" {
  description = "Name of CloudTrail"
  type        = string
}

variable "include_global_service_events" {
  description = "Determines if non-regional services like IAM will be logged via Cloud Trail"
  type        = bool
  default     = true
}

variable "ct_tags" {
  description = "Tags for Cloud Trail"
  type        = map(string)
  default     = {}
}

variable "trusted_iam_kms_admin_arns" {
  description = "ARNs of IAM entities that will have administrative access to CMK key associated with Cloud Trail"
  type        = list(string)
}

variable "trusted_iam_kms_usage_arns" {
  description = "ARNs of IAM entities that will have the ability decrypt, read, reencrypt, and describe the CMK key"
  type = list(string)
  default = []
}

variable "trusted_iam_kms_decrypt_arns" {
  description = "ARNs of IAM entities that will have the ability to only decrypt the CMK key via it's associated AWS account's CloudTrail"
  type = list(string)
  default = []
}

variable "bucket_name" {
  description = "Name of S3 bucket for Cloud Trail logs"
  type        = string
  default     = null
}

variable "key_prefix" {
  description = "S3 key prefix to put Cloud Trail logs under"
  type        = string
  default     = null
}

variable "cw_log_group_name" {
  description = "Name of Cloud Watch log group name"
  type        = string
  default     = "cloudtrail-logs"
}

variable "log_retention_days" {
  description = "Number of days Cloud Watch will retain the logs"
  type        = number
}

variable "aws_accounts" {
  description = <<EOF
AWS accounts that will write to the CloudTrail S3 bucket

Prereqs:
  - Module is not used to create organization trail (var.is_organization_trail = false)
  - Do not turn on CloudTrail in any of the acconts specified yet
EOF
  type = list(string)
  default = []
}