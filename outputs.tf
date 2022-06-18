output "child_accounts" {
  description = "Account configurations for AWS member accounts"
  value       = module.accounts.child_accounts
}
