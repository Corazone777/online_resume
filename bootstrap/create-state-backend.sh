#!/usr/bin/env bash
# Run ONCE, by hand, to create the S3 bucket + DynamoDB lock table that hold
# Terraform's remote state. These can't be managed by the same Terraform config
# that uses them (chicken-and-egg), so they're created out-of-band here.
#
# Pick globally-unique names. Bucket names are shared across all of AWS, so add
# something unique (your account id works well).
set -euo pipefail

REGION="us-east-1"
STATE_BUCKET="cloud-resume-tfstate-593901683489"   # <- must be globally unique
LOCK_TABLE="cloud-resume-tf-lock"

echo "Creating state bucket: $STATE_BUCKET"
# us-east-1 is special: it must NOT get a LocationConstraint.
aws s3api create-bucket \
  --bucket "$STATE_BUCKET" \
  --region "$REGION"

echo "Blocking all public access on the state bucket"
aws s3api put-public-access-block \
  --bucket "$STATE_BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Enabling versioning (lets you recover a clobbered state file)"
aws s3api put-bucket-versioning \
  --bucket "$STATE_BUCKET" \
  --versioning-configuration Status=Enabled

echo "Enabling default encryption"
aws s3api put-bucket-encryption \
  --bucket "$STATE_BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Creating lock table: $LOCK_TABLE"
aws dynamodb create-table \
  --table-name "$LOCK_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo
echo "Done. Put these in backend.tf:"
echo "  bucket         = \"$STATE_BUCKET\""
echo "  dynamodb_table = \"$LOCK_TABLE\""
