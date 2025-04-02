resource "aws_lambda_function" "hmac_authorizer" {
  function_name    = "ApiAuthorizer"
  role             = aws_iam_role.lambda_authorizer_role.arn
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
      BEARER_TOKEN = var.bearer_token
    }
  }
}

resource "aws_apigatewayv2_authorizer" "hmac_auth" {
  api_id          = aws_apigatewayv2_api.webhook_api.id
  name            = "ApiAuthorizer"
  authorizer_type = "REQUEST"
  authorizer_payload_format_version = "2.0"
  authorizer_uri  = aws_lambda_function.hmac_authorizer.invoke_arn
  identity_sources = ["$request.header.X-Zendesk-Webhook-Signature","$request.header.X-Zendesk-Webhook-Signature-Timestamp","$request.header.Authorization"]
  enable_simple_responses = true 
}

resource "aws_cloudwatch_log_group" "lambda_authorizer_log" {
  name              = "/aws/lambda/ApiAuthorizer"
  retention_in_days = 7
}


// Lambda authorizer role 
resource "aws_iam_role" "lambda_authorizer_role" {
  name = "lambda_authorizer_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}


resource "aws_iam_policy" "eventbridge_policy" {
  name        = "lambda_eventbridge_policy"
  description = "Policy for Lambda to put events in EventBridge"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:GetSamplingStatisticSummaries"
            ],
            "Resource": [
                "*"
            ]
        },
         {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/ApiAuthorizer:*"
    }

  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_eventbridge_attach" {
  role       = aws_iam_role.lambda_authorizer_role.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_authorizer_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}