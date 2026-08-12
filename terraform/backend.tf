# Remote state: keeps terraform.tfstate in S3 (shared, not on your laptop) so a
# GitHub Actions runner can read/write the same state. The DynamoDB table gives
# state locking, so two runs can't apply at once and corrupt state.
#
# NOTE: the bucket + lock table must EXIST before `terraform init` can use them.
# You can't create them in this same config (chicken-and-egg), so they're made
# once by the bootstrap script in bootstrap/ (or by hand). Fill in the names.
terraform {
  backend "s3" {
    bucket         = "cloud-resume-tfstate-593901683489"
    key            = "cloud-resume/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloud-resume-tf-lock"
    encrypt        = true
  }
}
