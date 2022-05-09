%{ for account in accounts ~}

provider "aws" {
  assume_role {
    role_arn = "${account.role_arn}"
  }
  alias = "${account.name}"
}

module "${account.name}_config" {
  source = "..//account-config"
  logs_arn = "${logs_arn}"
  providers = {
    aws = aws.${account.name}
  }
  enable_cfg_recorder        = "${cfg_is_active}"
}

%{ endfor ~}