
# IAM Role for the Lambda
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
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.eventbridge_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

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
      "Resource": "arn:aws:logs:eu-west-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/support_case_monitor:*"
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
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ],
      "Resource": "${aws_s3_bucket.case_id_lookup.arn}/*"
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
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      EVENT_BUS_ARN       = aws_cloudwatch_event_bus.webhook_event_bus.arn
      S3_BUCKET_NAME      = aws_s3_bucket.case_id_lookup.id
      ZENDESK_TOKEN       = var.zendesk_token
      ZENDESK_SUBDOMAIN   = var.zendesk_subdomain
      ZENDESK_ADMIN_EMAIL = var.zendesk_admin_email
    }
  }
}
