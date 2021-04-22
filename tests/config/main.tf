module "mut_config" {
  source = "../../modules//config"

  rules = [
    {
      name              = "test-ct-enabled"
      source            = "AWS"
      source_identifier = "CLOUD_TRAIL_ENABLED"
    }
  ]

}
