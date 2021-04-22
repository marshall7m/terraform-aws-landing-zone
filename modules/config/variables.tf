variable "enable_cfg_recorder" {
  description = "Determines if the AWS Config recorder is active for the account"
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "Determines if AWS Config is region agnostic for recorded resources"
  type        = bool
  default     = true
}

variable "cfg_name" {
  description = "Name of AWS Config"
  type        = string
  default     = null
}

variable "cfg_logs_bucket" {
  description = "Name of AWS S3 bucket used to store AWS config logs"
  type        = string
  default     = null
}

variable "cfg_logs_prefix" {
  description = "Prefix to store logs under within S3 bucket"
  type        = string
  default     = null
}

variable "cfg_delivery_frequency" {
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