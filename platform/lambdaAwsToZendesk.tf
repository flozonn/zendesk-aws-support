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


# Attach IAM policies to Lambda role

resource "aws_iam_role_policy_attachment" "lambda_lookup_db_attach" {
  role       = aws_iam_role.lambda_support_case_role.name
  policy_arn = aws_iam_policy.lookup_db_policy.arn
}
resource "aws_iam_role_policy_attachment" "lambda_defaultbus_attach" {
  role       = aws_iam_role.lambda_support_case_role.name
  policy_arn = aws_iam_policy.default_bus_access_policy.arn
}
resource "aws_iam_role_policy_attachment" "lambda_api_secret_attach" {
  role       = aws_iam_role.lambda_support_case_role.name
  policy_arn = aws_iam_policy.get_api_secret_policy.arn
}
resource "aws_iam_role_policy_attachment" "read_support_cases_attach" {
  role       = aws_iam_role.lambda_support_case_role.name
  policy_arn = aws_iam_policy.edit_support_cases.arn
}
resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_support_case_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
  runtime          = "python3.13"
  handler          = "handler.lambda_handler"
  filename         = "${path.module}/../dist/aws_to_zendesk.zip"
  source_code_hash = filebase64sha256("${path.module}/../dist/aws_to_zendesk.zip")
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
