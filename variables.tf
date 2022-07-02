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
    is_cfg                     = optional(bool)
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
  default     = 14
}

variable "ct_name" {
  description = "Name of CloudTrail"
  type        = string
  default     = "org-cloudtrail"
}

#### CONFIG ####

variable "cfg_is_active" {
  description = "Determines if AWS Config recorder is active in each child account within organization"
  type        = bool
  default     = true
}

variable "cfg_managed_rules" {
  description = "List of AWS managed rules to apply to provider's account"
  type = list(object({
    name                        = string
    description                 = optional(string)
    excluded_accounts           = optional(list(string))
    exclude_root                = optional(bool)
    input_parameters            = optional(map(string))
    rule_identifier             = string
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  }))
  default = []
}

variable "cfg_custom_rules" {
  description = "List of custom or AWS managed rules to apply to provider's account"
  type = list(object({
    name                        = string
    description                 = optional(string)
    excluded_accounts           = optional(list(string))
    exclude_root                = optional(bool)
    input_parameters            = optional(map(string))
    rule_identifier             = string
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))

    function_name = optional(string)
    handler       = string
    runtime       = string
    env_vars      = optional(map(string))
    filename      = optional(string)
    image_uri     = optional(string)
    s3_bucket     = optional(string)
    s3_key        = optional(string)
  }))
  default = []
}

variable "ct_enabled_rule" {
  description = <<EOF
Configurations for default rule: CLOUD_TRAIL_ENABLED. Rule checks if Cloudtrail is 
enabled within each account that's not within 
`excluded_accounts` attribute"
  EOF
  type = object({
    enable                      = optional(bool)
    name                        = optional(string)
    excluded_accounts           = optional(list(string))
    exclude_root                = optional(bool)
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  })
  default = {}
}

variable "gd_enabled_centralized_rule" {
  description = <<EOF
Configurations for default rule: GUARDDUTY_ENABLED_CENTRALIZED. Rule checks if GuardDuty is 
enabled within the config AWS account ID. Config AWS account can be specified via is_cfg attribute within `var.child_accounts`
  EOF
  type = object({
    enable                      = optional(bool)
    name                        = optional(string)
    excluded_accounts           = optional(list(string))
    exclude_root                = optional(bool)
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  })
  default = {}
}

variable "ct_cw_logs_enabled_rule" {
  description = <<EOF
Configurations for default rule: CLOUD_TRAIL_CLOUD_WATCH_LOGS_ENABLED. Rule checks if 
CloudTrail CloudWatch logs are enabled within AWS Organization's master account
  EOF
  type = object({
    enable                      = optional(bool)
    name                        = optional(string)
    excluded_accounts           = optional(list(string))
    exclude_root                = optional(bool)
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  })
  default = {}
}

variable "account_part_of_org_rule" {
  description = <<EOF
Configurations for default rule: ACCOUNT_PART_OF_ORGANIZATIONS. Rule checks if 
member AWS account's organization master account ID is valid
  EOF
  type = object({
    enable                      = optional(bool)
    name                        = optional(string)
    excluded_accounts           = optional(list(string))
    exclude_root                = optional(bool)
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  })
  default = {}
}
