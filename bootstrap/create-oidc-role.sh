#!/usr/bin/env bash
# Run ONCE to let GitHub Actions authenticate to AWS with NO stored keys (OIDC).
# It creates: (1) the GitHub OIDC identity provider in your account, and
# (2) an IAM role that only YOUR repo's workflows can assume.
set -euo pipefail

REGION="us-east-1"
ACCOUNT_ID="593901683489"
GITHUB_USER="Corazone777"
REPO_NAME="online_resume" 
ROLE_NAME="github-actions-cloud-resume"

# 1. Create the GitHub OIDC provider (skip/ignore error if it already exists).
echo "Creating GitHub OIDC provider (ok if it already exists)..."
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "ffffffffffffffffffffffffffffffffffffffff" \
  2>/dev/null || echo "  provider already exists, continuing"

# 2. Trust policy: only workflows from this exact repo may assume the role.
#    The sub condition scopes it to your repo (any branch).
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_USER}/${REPO_NAME}:*"
        }
      }
    }
  ]
}
EOF

echo "Creating role $ROLE_NAME..."
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file:///tmp/trust-policy.json

echo
echo "Role created. Its ARN (put this in the workflows as AWS_ROLE_ARN):"
aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text
echo
echo "NEXT: attach a permissions policy to this role (see permissions-policy.json)."
