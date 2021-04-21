%{ for account in accounts ~}
module "${account.name}_config" {
  source = "..//config"
  logs_org_role_arn = "${logs_org_role_arn}"
  provider_role_arn = "${account.role_arn}"
  enable_cfg_recorder        = "${cfg_is_active}"
}

%{ endfor ~}