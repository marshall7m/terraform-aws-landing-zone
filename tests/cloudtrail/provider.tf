provider "aws" {
  alias = "ct"
  assume_role {
    role_arn = "arn:aws:iam::${var.ct_id}:role/cross-account-admin-access"
  }
  region = "us-west-2"
}

provider "aws" {
  alias = "s3"
  assume_role {
    role_arn = "arn:aws:iam::${var.s3_id}:role/cross-account-admin-access"
  }
  region = "us-west-2"
}