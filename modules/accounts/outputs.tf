output "child_accounts" {
  value = [ for account in local.child_accounts: merge(
    aws_organizations_account.this[account.name], 
    {role_arn = "arn:aws:iam::${aws_organizations_account.this[account.name].id}:role/${account.role_name}"}
  )]
}