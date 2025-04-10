
resource "aws_secretsmanager_secret" "api_key" {
  name = "api_key"
  description = "API gateway API key"
}

data "aws_iam_policy_document" "gateway_secret_policy" {
  statement {
    sid    = "EnableLambdaToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_lambda_function.authorizer.role]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.api_key.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "zendesk_gateway_secret_policy" {
  secret_arn = aws_secretsmanager_secret.api_key.arn
  policy     = data.aws_iam_policy_document.gateway_secret_policy.json
}

resource "aws_secretsmanager_secret_version" "gateway_secret_version" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.bearer_token
}