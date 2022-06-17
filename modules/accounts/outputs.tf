output "child_accounts" {
  value = { for account in aws_organizations_account.this : account.name => merge(
    account,
    { role_arn = "arn:aws:iam::${account.id}:role/${account.role_name}" }
  ) }
}