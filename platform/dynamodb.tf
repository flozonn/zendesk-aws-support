resource "aws_dynamodb_table" "idlookup" {
  name         = "idslookup"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id-z"
  attribute {
    name = "id-z"
    type = "S"
  }
  tags = {
    Name = "Zendesk-lookup"
  }
}

