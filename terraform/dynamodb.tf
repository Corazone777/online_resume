# The counter table. Terraform manages the TABLE, not the item inside it -
# your existing {id="visitors", count=N} item is left untouched by import, so
# your current visitor count survives.
resource "aws_dynamodb_table" "counter" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # on-demand: no capacity to provision
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
