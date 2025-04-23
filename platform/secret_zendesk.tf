resource "aws_secretsmanager_secret" "zendesk_api_key" {
  name        = "zendesk_api_key"
  description = "External Zendesk API key"
  kms_key_id  = aws_kms_key.dynamo.arn
}

resource "aws_secretsmanager_secret_version" "zendesk_secret_version" {
  secret_id      = aws_secretsmanager_secret.zendesk_api_key.id
  secret_string  = var.zendesk_token
  version_stages = ["AWSCURRENT"]

}
