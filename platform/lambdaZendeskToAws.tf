data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_event_listener_role" {
  name               = "lambda_event_listener_role"
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

# Permissions pour la Lambda
resource "aws_iam_policy" "lambda_eventbridge_policy_listener" {
  name        = "lambda_eventbridge_policy_listener"
  description = "Allow Lambda to interact with a specific EventBridge bus"

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
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:eu-central-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/event_listener_lambda:*"
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
        "Action": ["support:*"],
        "Resource": "*"
    }
  ]
}
EOF
}

# Attacher la policy à la Lambda
resource "aws_iam_role_policy_attachment" "lambda_to_eventbridge_attach" {
  role       = aws_iam_role.lambda_event_listener_role.name
  policy_arn = aws_iam_policy.lambda_eventbridge_policy_listener.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_listener" {
  role       = aws_iam_role.lambda_event_listener_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Groupe de logs pour la Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group_listener" {
  name              = "/aws/lambda/event_listener_lambda"
  retention_in_days = 7
}

# Définition de la Lambda
resource "aws_lambda_function" "event_listener_lambda" {
  function_name    = "lambdaZendeskToAws"
  role             = aws_iam_role.lambda_event_listener_role.arn
  runtime          = "python3.9"
  handler          = "lambdaZendeskToAws.lambda_handler"
  filename         = "../lambdaZendeskToAws/lambdaZendeskToAws.zip"
  source_code_hash = filebase64sha256("../lambdaZendeskToAws/lambdaZendeskToAws.zip")
  timeout          = 15
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      EVENT_BUS_ARN      = aws_cloudwatch_event_bus.webhook_event_bus.arn
      TABLE_NAME          = aws_dynamodb_table.idlookup.name

    }
  }
}

