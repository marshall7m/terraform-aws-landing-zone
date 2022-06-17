variable "logs_arn" {
  description = "ARN of the account to create the AWS S3 bucket and KMS CMK. If not specified, defaults to primary provider."
  type        = string
  default     = null
}

variable "enable_recorder" {
  description = "Determines if the AWS Config recorder is active for the account"
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "Determines if AWS Config is region agnostic for recorded resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name of AWS Config"
  type        = string
  default     = "account-config"
}

variable "delivery_frequency" {
  description = "Frequency for AWS Config to deliver configuration snapshots"
  type        = string
  default     = "Six_Hours"
}

variable "maximum_execution_frequency" {
  description = "Default maximum frequency that AWS config evaluates rules"
  type        = string
  default     = "TwentyFour_Hours"
}

variable "rules" {
  description = "List of custom or AWS managed rules to apply to provider's account"
  type = list(object({
    name                        = string
    description                 = optional(string)
    input_parameters            = optional(string)
    source                      = string
    source_identifier           = string
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  }))
  default = []
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