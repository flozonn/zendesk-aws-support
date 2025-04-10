resource "aws_iam_role" "lambda_support_case_role" {
  name = "lambda_support_case_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for Lambda to read from EventBridge and log to CloudWatch
resource "aws_iam_policy" "lambda_support_case_policy" {
  name        = "lambda_support_case_policy"
  description = "Allow Lambda to read support case events from EventBridge"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "events:DescribeRule",
        "events:*",
        "events:GetEventBus"
      ],
     "Resource": "arn:aws:events:eu-west-1:619071325606:event-bus/default"
    },
        {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/lambdaAwsToZendesk:*"
    },
      {
            "Sid": "SpecificTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:CreateTable",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": "${aws_dynamodb_table.idlookup.arn}"
        },
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
        },
              {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "${aws_secretsmanager_secret.zendesk_api_key.arn}"
            ]
        }

  ]
}
EOF
}

# Attach IAM policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_support_case_attach" {
  role       = aws_iam_role.lambda_support_case_role.name
  policy_arn = aws_iam_policy.lambda_support_case_policy.arn
}

# CloudWatch log group for Lambda
resource "aws_cloudwatch_log_group" "lambda_support_case_log" {
  name              = "/aws/lambda/lambdaAwsToZendesk"
  retention_in_days = 7
}

# Lambda Function
resource "aws_lambda_function" "support_case_monitor_lambda" {
  function_name    = "lambdaAwsToZendesk"
  role             = aws_iam_role.lambda_support_case_role.arn
  runtime          = "python3.9"
  handler          = "lambdaAwsToZendesk.lambda_handler"
  filename         = "../lambdaAwsToZendesk/lambdaAwsToZendesk.zip"
  source_code_hash = filebase64sha256("../lambdaAwsToZendesk/lambdaAwsToZendesk.zip")
  timeout          = 15
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      EVENT_BUS_ARN       = aws_cloudwatch_event_bus.webhook_event_bus.arn
      ZENDESK_SUBDOMAIN   = var.zendesk_subdomain
      ZENDESK_ADMIN_EMAIL = var.zendesk_admin_email
      TABLE_NAME          = aws_dynamodb_table.idlookup.name
      REGION_NAME         = var.region
    }
  }
}
