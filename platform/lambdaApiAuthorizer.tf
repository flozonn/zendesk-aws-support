resource "aws_lambda_function" "hmac_authorizer" {
  function_name    = "HMACAuthorizer"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "lambdaApiAuthorizer.lambda_handler"
  filename         = "../lambdaApiAuthorizer/lambdaApiAuthorizer.zip"
  source_code_hash = filebase64sha256("../lambdaApiAuthorizer/lambdaApiAuthorizer.zip")
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      WEBHOOK_SECRET_CREATE = var.webhook_secret_create
      WEBHOOK_SECRET_UPDATE = var.webhook_secret_update
      WEBHOOK_SECRET_SOLVED = var.webhook_secret_solved
    }
  }
}

resource "aws_apigatewayv2_authorizer" "hmac_auth" {
  api_id          = aws_apigatewayv2_api.webhook_api.id
  name            = "HMACAuthorizer"
  authorizer_type = "REQUEST"
  authorizer_payload_format_version = "2.0"
  authorizer_uri  = aws_lambda_function.hmac_authorizer.invoke_arn
  identity_sources = ["$request.header.X-Zendesk-Webhook-Signature","$request.header.X-Zendesk-Webhook-Signature-Timestamp"]
  enable_simple_responses = true 
}

resource "aws_cloudwatch_log_group" "lambda_authorizer_log" {
  name              = "/aws/lambda/HMACAuthorizer"
  retention_in_days = 7
}
