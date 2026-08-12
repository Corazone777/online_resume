output "function_url" {
  description = "Public URL the frontend calls. Paste this into COUNTER_API in your site JS."
  value       = aws_lambda_function_url.counter.function_url
}

output "table_name" {
  description = "DynamoDB table backing the counter."
  value       = aws_dynamodb_table.counter.name
}
