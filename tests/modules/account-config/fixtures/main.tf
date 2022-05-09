module "mut_account_config" {
  source = "../../../../modules//account-config"
  rules = [
    {
      name              = "test-ct-enabled"
      source            = "AWS"
      source_identifier = "CLOUD_TRAIL_ENABLED"
    }
  ]
}