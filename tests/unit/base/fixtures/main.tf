
module "mut_base" {
  source = "../../../../"
  providers = {
    aws = aws
  }
  child_accounts = [
    {
      name      = "test_logs_account"
      email     = "test+mut_base_logs@gmail.com"
      role_name = "TestOrg"
      is_logs   = true
    },
    {
      name      = "test_cfg_account"
      email     = "test+mut_base_cfg@gmail.com"
      role_name = "TestOrg"
      is_cfg    = true
    }
  ]
  ct_name               = "mut-terraform-aws-landing-zone-base"
  ct_log_retention_days = 1
}

