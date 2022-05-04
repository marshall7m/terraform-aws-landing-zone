module "mut_base" {
  source = "../../modules//base"
  child_accounts = [
    {
      name      = "test_account"
      email     = "test+mut.base@gmail.com"
      role_name = "TestOrg"
      is_logs   = true
    }
  ]
  ct_name               = "mut-terraform-aws-landing-zone-base"
  ct_log_retention_days = 1
}