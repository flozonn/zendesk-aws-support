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

# Attacher la policy à la Lambda
resource "aws_iam_role_policy_attachment" "lambda_lookup_db" {
  role       = aws_iam_role.lambda_event_listener_role.name
  policy_arn = aws_iam_policy.lookup_db_policy.arn
}
resource "aws_iam_role_policy_attachment" "webhook_bus_access_policy_attachment" {
  role       = aws_iam_role.lambda_event_listener_role.name
  policy_arn = aws_iam_policy.webhook_bus_access_policy.arn
}
resource "aws_iam_role_policy_attachment" "logging_tracing_policy_attachment" {
  role       = aws_iam_role.lambda_event_listener_role.name
  policy_arn = aws_iam_policy.logging_tracing_policy.arn
}
resource "aws_iam_role_policy_attachment" "edit_support_cases_attachment" {
  role       = aws_iam_role.lambda_event_listener_role.name
  policy_arn = aws_iam_policy.edit_support_cases.arn
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
  runtime          = "python3.13"
  handler          = "handler.lambda_handler"
  filename         = "${path.module}/../dist/zendesk_to_aws.zip"
  source_code_hash = filebase64sha256("${path.module}/../dist/zendesk_to_aws.zip")
  timeout          = 15
  tracing_config {
    mode = "Active"
  }
  environment {
    variables = {
      EVENT_BUS_ARN = aws_cloudwatch_event_bus.webhook_event_bus.arn
      TABLE_NAME    = aws_dynamodb_table.idlookup.name

    }
  }
}

