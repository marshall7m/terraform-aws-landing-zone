resource "aws_organizations_organization" "this" {
  count                         = var.create_organization ? 1 : 0
  aws_service_access_principals = var.aws_service_access_principals

  feature_set = var.feature_set
}

locals {
  #sets product for account and each associated policy
  account_policies = chunklist(flatten([for account in var.child_accounts : try(setproduct([account.name], account.policies), [])]), 2)
  child_accounts = [for account in var.child_accounts : defaults(account, {
    role_name                  = "OrganizationAccountAccessRole"
    iam_user_access_to_billing = false
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
  # iam_user_access_to_billing = each.value.iam_user_access_to_billing ? "ALLOW" : "DENY"
  iam_user_access_to_billing = null
  tags                       = each.value.tags

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name]
  }
}