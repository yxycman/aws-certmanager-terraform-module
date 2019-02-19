terraform {
  required_version = ">= 0.11.7, < 0.12"
}

provider "aws" {
  region  = "${var.region}"
  version = "~>1.5"

  assume_role {
    role_arn = "${var.role-arn}"
  }
}

provider "template" {
  version = "~> 1.0"
}

provider "null" {
  version = "~>1.0"
}
