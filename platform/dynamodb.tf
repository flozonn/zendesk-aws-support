resource "aws_dynamodb_table" "idlookup" {
  name         = "idslookup"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id-z"
  attribute {
    name = "id-z"
    type = "S"
  }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo.arn
  }
  point_in_time_recovery {
    enabled = true
  }
  tags = {
    Name = "Zendesk-lookup"
  }
}

