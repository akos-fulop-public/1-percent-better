resource "aws_dynamodb_table" "hello_world_db_table" {
  name = "hello_world_db_table"
  hash_key = "TestTableHashKey"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "TestTableHashKey"
    type = "S"
  }

  tags = {
    Name = "Hello-World-db-table"
  }
}
