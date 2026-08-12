# Zip the handler at plan/apply time. boto3 ships in the runtime and there are
# no other deps, so packaging the single .py file is enough. Adjust the path if
# your lambda_function.py lives somewhere other than ../visitor-counter/.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../visitor_counter/lambda_function.py"
  output_path = "${path.module}/build/lambda_function.zip"
}

resource "aws_lambda_function" "counter" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DDB_TABLE      = var.table_name
      COUNTER_ID     = var.counter_id
      ALLOWED_ORIGIN = var.allowed_origin
    }
  }
}

# The public HTTP endpoint. CORS is handled in the Lambda code, so no cors{}
# block here (adding one would double the Access-Control-Allow-Origin header).
resource "aws_lambda_function_url" "counter" {
  function_name      = aws_lambda_function.counter.function_name
  authorization_type = "NONE"
}

# Public function URLs need a resource-based permission allowing anonymous
# invoke. The console added this automatically with statement id
# "FunctionURLAllowPublicAccess" - confirm yours with `aws lambda get-policy`.
resource "aws_lambda_permission" "allow_public_url" {
  statement_id           = "FunctionURLAllowPublicAccess"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.counter.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}

resource "aws_lambda_permission" "allow_invoke_function" {
  statement_id  = "FunctionURLAllowInvokeAction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.counter.function_name
  principal     = "*"
}
