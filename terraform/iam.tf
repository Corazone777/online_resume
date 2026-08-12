# The role the Lambda assumes at runtime.
resource "aws_iam_role" "lambda_exec" {
  name = var.role_name
  path = "/service-role/"
  # Trust policy: only the Lambda service may assume this role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# The AWS-managed policy the console attached automatically - lets the
# function write to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Your hand-written least-privilege policy: this Lambda may only UpdateItem,
# and only on this one table. NOTE: the `name` here must match the name of the
# inline policy you created in the console for the import to line up - check it
# with `aws iam list-role-policies --role-name <role>` and adjust if needed.
resource "aws_iam_role_policy" "dynamodb_update" {
  name = "counter"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowUpdateItem"
      Effect   = "Allow"
      Action   = "dynamodb:UpdateItem"
      Resource = aws_dynamodb_table.counter.arn
    }]
  })
}
