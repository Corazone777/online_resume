# Lambda auto-creates this log group on first run; bringing it under Terraform
# lets you control retention (default is "never expire" = slowly accumulating
# cost). Import it, or delete this file if you'd rather leave it unmanaged.
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}
