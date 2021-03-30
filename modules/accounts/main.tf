resource "aws_organizations_organization" "this" {
  count = var.create_organization ? 1 : 0
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com"
  ]

  feature_set = "ALL"
}

locals {
  #sets product for account and each associated policy
  account_policies = chunklist(flatten([for account in var.child_accounts : try(setproduct([account.name], account.policies), [])]), 2)
  child_accounts = [for account in var.child_accounts: defaults(account, {
    is_logs = false
  })]
}

resource "aws_organizations_policy" "this" {
  for_each = { for policy in var.policies : policy.name => policy.content }
  name     = each.key
  content  = <<CONTENT
${each.value}
CONTENT
}


resource "aws_organizations_policy_attachment" "this" {
  count     = length(local.account_policies)
  policy_id = aws_organizations_policy.this[local.account_policies[count.index][1]].id
  target_id = aws_organizations_account.this[local.account_policies[count.index][0]].id
}

resource "aws_organizations_account" "this" {
  for_each  = { for account in local.child_accounts : account.name => account }
  name      = each.value.name
  parent_id = each.value.parent_id
  email     = each.value.email
  role_name = each.value.role_name
  iam_user_access_to_billing = each.value.iam_user_access_to_billing == null ? null : each.value.iam_user_access_to_billing ? "ALLOW" : "DENY"
  tags = each.value.tags
}

# resource "aws_cloudtrail" "this" {
#   name                          = var.cloud_trail_name
#   s3_bucket_name                = var.cloud_trail_bucket_name
#   include_global_service_events = var.cloud_trail_include_global_service_events
#   is_organization_trail = true
#   is_multi_region_trail = true
# }