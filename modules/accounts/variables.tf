variable "create_organization" {
  description = "Determines if an AWS Organization should be created (to import pre-existing Organization, use `terraform import aws_organizations_organization.this <organization_name>`)"
  type        = bool
  default     = true
}

variable "child_accounts" {
  description = "List of AWS child accounts and their respective configurations"
  /* 
 change to below when issue: https://github.com/hashicorp/terraform/issues/19898 is fixed to allow optional map  
    type = list(object({
        name = string
        email = string
        role_name = string
        policies = list(string)
    }))
*/
  type    = any
  default = null
}

variable "policies" {
  description = "List of account policies that can be attached to child accounts"
  type = list(object({
    name    = string
    content = string
  }))
  default = null
}

