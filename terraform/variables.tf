variable "aws_region" {
  description = "Region the counter backend runs in (matches the console-created resources)."
  type        = string
  default     = "us-east-1"
}

variable "table_name" {
  description = "DynamoDB table name. Must match the existing table exactly for import."
  type        = string
  default     = "visitor_counter"
}

variable "counter_id" {
  description = "Partition-key value of the single counter item."
  type        = string
  default     = "visitors"
}

variable "allowed_origin" {
  description = "Origin allowed to call the Function URL (scheme + host, no trailing slash)."
  type        = string
  default     = "https://cv.atlas-arcade-tech.com"
}

# No defaults for these two: they were auto-named by the console, so you must
# discover them (see README) and set them in terraform.tfvars before importing.
variable "function_name" {
  description = "Existing Lambda function name."
  type        = string
}

variable "role_name" {
  description = "Name of the Lambda's existing execution role."
  type        = string
}
