output "child_accounts" {
  value = aws_organizations_account.this
}

#role used for provisioning Cloudtrail S3 bucket and KMS CMK within `..//base` module
output "logs_org_role_arn" {
  value = one([for account in local.child_accounts :
  "arn:aws:iam::${aws_organizations_account.this[account.name].id}:role/${aws_organizations_account.this[account.name].role_name}" if account.is_logs])
}