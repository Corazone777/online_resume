# The counter backend lives in us-east-1 (Lambda + DynamoDB). Note this is a
# DIFFERENT provider target than your Atlas project's DigitalOcean setup, and
# separate from the S3 bucket in eu-north-1 (which Terraform doesn't manage here).
provider "aws" {
  region = var.aws_region
}
