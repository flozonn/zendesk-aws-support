resource "aws_secretsmanager_secret" "zendesk_api_key" {
  name = "zendesk_api_key"
  description = "External Zendesk API key"
}

data "aws_iam_policy_document" "secret_policy" {
  statement {
    sid    = "EnableLambdaToReadTheSecret"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_lambda_function.support_case_monitor_lambda.role]
    }

    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.zendesk_api_key.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "zendesk_secret_policy" {
  secret_arn = aws_secretsmanager_secret.zendesk_api_key.arn
  policy     = data.aws_iam_policy_document.secret_policy.json
}

resource "aws_secretsmanager_secret_version" "zendesk_secret_version" {
  secret_id     = aws_secretsmanager_secret.zendesk_api_key.id
  secret_string = var.zendesk_token
}
