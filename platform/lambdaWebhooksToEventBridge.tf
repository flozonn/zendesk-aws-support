resource "aws_iam_role" "lambda_role" {
  name = "lambda_webhook_role"

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
        "events:PutEvents",
        "events:GetEventBus"
      ],
       "Resource": "${aws_cloudwatch_event_bus.webhook_event_bus.arn}"
    }
    ,
    {
        "Effect": "Allow",
        "Action": ["support:*"],
        "Resource": "*"
    },
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
        }

  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_eventbridge_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/webhook_lambda"
  retention_in_days = 7
}

resource "aws_lambda_function" "webhook_lambda" {
  function_name    = "webhook_lambda"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.9"
  handler          = "lambdaWebhooksToEventBridge.lambda_handler"
  filename         = "../lambdaWebhooksToEventBridge/lambdaWebhooksToEventBridge.zip"
  source_code_hash = filebase64sha256("../lambdaWebhooksToEventBridge/lambdaWebhooksToEventBridge.zip")

  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      EVENT_BUS_ARN         = aws_cloudwatch_event_bus.webhook_event_bus.arn
      WEBHOOK_SECRET_CREATE = var.webhook_secret_create
      WEBHOOK_SECRET_UPDATE = var.webhook_secret_update
      WEBHOOK_SECRET_SOLVED = var.webhook_secret_solved
    }
  }
}

resource "aws_lambda_function_url" "webhook_lambda_url" {
  function_name      = aws_lambda_function.webhook_lambda.function_name
  authorization_type = "NONE"
}

output "lambda_function_url" {
  value = aws_lambda_function_url.webhook_lambda_url.function_url
}

