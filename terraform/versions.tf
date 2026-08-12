# Pin Terraform and provider versions so this builds the same way on any
# machine (and in CI later). Loose upper bounds keep you on 5.x / 2.x.
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}
