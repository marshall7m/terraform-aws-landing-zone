variable "cfg_role_arn" {
  description = "AWS IAM role ARN the AWS provider will assume to create AWS Config resources in"
  type        = string
  default     = null
}

variable "logs_role_arn" {
  description = "AWS IAM role ARN the AWS provider will assume to create AWS S3 bucket and AWS KMS CMK to store AWS Config history"
  type        = string
  default     = null
}

variable "aggregator_name" {
  description = "Name for AWS Config aggregator"
  type        = string
  default     = null
}

variable "enable_recorder" {
  description = "Determines if the AWS Config recorder is active for the account"
  type        = bool
  default     = true
}

variable "recorder_name" {
  description = "Name for AWS Config recorder"
  type        = string
  default     = null
}

variable "include_global_resource_types" {
  description = "Determines if AWS Config is region agnostic for recorded resources"
  type        = bool
  default     = true
}

variable "delivery_channel_name" {
  description = "Name for AWS Config delivery channel"
  type        = string
  default     = null
}

variable "delivery_frequency" {
  description = "Frequency for AWS Config to deliver configuration snapshots"
  type        = string
  default     = "Six_Hours"
}

variable "bucket_key_prefix" {
  description = "Prefix for AWS S3 bucket used to store AWS Config logs"
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "AWS S3 bucket used to store AWS Config logs"
  type        = string
  default     = null
}

variable "kms_key_trusted_admin_arns" {
  description = "Trusted ARNs that will have administrative permissions for AWS KMS CMK"
  type        = list(string)
  default     = []
}

variable "managed_rules" {
  description = "List of AWS managed rules to apply to specified organization accounts"
  type = list(object({
    name                        = string
    description                 = optional(string)
    excluded_accounts           = optional(list(string))
    input_parameters            = optional(map(string))
    rule_identifier             = string
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  }))
  default = []
}

variable "custom_rules" {
  description = "List of custom rules to apply to specified organization accounts"
  type = list(object({
    name                        = string
    description                 = optional(string)
    excluded_accounts           = optional(list(string))
    input_parameters            = optional(map(string))
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

variable "conformance_packs" {
  description = "List of conformance packs to apply to AWS Organization accounts"
  type = list(object({
    name = string
    inputs_parameters = optional(list(object({
      name  = string
      value = string
    })))
    template_body   = optional(string)
    template_s3_uri = optional(string)
  }))
  default = []
}