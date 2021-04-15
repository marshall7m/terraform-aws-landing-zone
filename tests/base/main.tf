terraform {
  required_version = ">= 0.15.0"
}

variable "testing_email" {
  type    = string
  default = "test+mut.base@gmail.com"
}

module "mut_base" {
  source = "../../modules//base"
  child_accounts = [
    {
      name      = "test_account"
      email     = var.testing_email
      role_name = "TestOrg"
      is_logs   = true
    }
  ]
  ct_name               = "mut-terraform-aws-landing-zone-base"
  ct_log_retention_days = 1
}