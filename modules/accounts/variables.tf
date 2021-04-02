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

variable "policies" {
  description = "List of account policies that can be attached to child accounts"
  type = list(object({
    name    = string
    content = string
  }))
  default = []
}

