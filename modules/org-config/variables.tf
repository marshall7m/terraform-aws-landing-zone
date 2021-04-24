variable "cfg_role_arn" {
  description = "AWS IAM role ARN the AWS provider will assume"
  type        = string
  default     = null
}

variable "managed_rules" {
  description = "List of custom or AWS managed rules to apply to provider's account"
  type = list(object({
    name                        = string
    description                 = optional(string)
    excluded_accounts = optional(list(string))
    input_parameters            = optional(string)
    source                      = string
    rule_identifier           = string
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))
  }))
  default = []
}

variable "custom_rules" {
  description = "List of custom or AWS managed rules to apply to provider's account"
  type = list(object({
    name                        = string
    description                 = optional(string)
    excluded_accounts = optional(list(string))
    input_parameters            = optional(string)
    source                      = string
    rule_identifier           = string
    maximum_execution_frequency = optional(string)
    tags                        = optional(map(string))

    function_name = optional(string)
    handler = string
    runtime = string
    env_vars = optional(map(string))
    filename = optional(string)
    image_uri = optional(string)
    s3_bucket = optional(string)
    s3_key = optional(string)
  }))
  default = []
}