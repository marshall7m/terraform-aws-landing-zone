include {
  path = find_in_parent_folders()
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("aws.hcl"))
  id           = local.account_vars.locals.account_id
}

inputs = {
  ct_id = local.id
  s3_id = local.id
}