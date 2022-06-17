module "mut_accounts" {
  source = "../../../../modules//accounts"

  create_organization = true
  policies = [
    {
      name    = "tags"
      content = jsonencode(yamldecode(file("${path.module}/policies.yaml")))
    }
  ]
  child_accounts = [
    {
      name      = "entrypoint"
      email     = "test+@gmail.com"
      role_name = "TestOrg"

    },
    {
      name      = "shared-services"
      email     = "test+@gmail.com"
      role_name = "TestOrg"

    },
    {
      name      = "dev"
      email     = "test+@gmail.com"
      role_name = "TestOrg"

    },
    {
      name      = "staging"
      email     = "test+@gmail.com"
      role_name = "TestOrg"
    },
    {
      name      = "prod"
      email     = "test+@gmail.com"
      role_name = "TestOrg"

    }
  ]
}