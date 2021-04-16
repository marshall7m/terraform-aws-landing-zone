#### ACCOUNTS ####

variable "create_organization" {
  description = "Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`)"
  type        = bool
  default     = true
}

variable "child_accounts" {
  description = "List of AWS child accounts and their respective configurations"
  type = list(object({
    name                       = string
    email                      = string
    role_name                  = optional(string)
    parent_id                  = optional(string)
    policies                   = optional(list(string))
    tags                       = optional(map(string))
    is_logs                    = optional(bool)
    iam_user_access_to_billing = optional(bool)
  }))
  default = []
}

variable "account_policies" {
  description = "List of account policies that can be attached to child accounts"
  type = list(object({
    name    = string
    content = string
  }))
  default = []
}

#### GUARDDUTY ####

variable "enabled_gd" {
  description = "Determines if organization-level Guard Duty should be used"
  type        = bool
  default     = true
}

variable "gd_is_active" {
  description = "Determines if Guard Duty is active (only suspends Guard Duty activity if false)"
  type        = bool
  default     = true
}

variable "create_gd_s3_bucket" {
  description = "Determines if Guard Duty findings should be publised to a S3 bucket within the logs account"
  type        = bool
  default     = true
}

variable "gd_bucket_name" {
  description = "S3 bucket to publish Guard Duty findings to"
  type        = string
  default     = null
}

variable "gd_deny_uncrypted_uploads" {
  description = "Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uncrypted uploads"
  type        = bool
  default     = true
}

variable "gd_deny_invalid_crypted_headers" {
  description = "Determines if a S3 policy statement should be added to Guard duty associated bucket to deny uploads with invalid crypted headers"
  type        = bool
  default     = true
}

#### CLOUDTRAIL ####

variable "enable_ct" {
  description = "Determines if organization-level Cloudtrail should be used"
  type        = bool
  default     = true
}

variable "ct_is_active" {
  description = "Determines if Cloudtrail logging is active (only suspends Cloudtrail logging if false)"
  type        = bool
  default     = true
}

variable "ct_log_retention_days" {
  description = "Number of days Cloud Watch will retain the logs"
  type        = number
}

variable "ct_name" {
  description = "Name of CloudTrail"
  type        = string
}