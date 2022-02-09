
data "archive_file" "zip" {
  type        = "zip"
  source_file = "hello_lambda.py"
  output_path = "hello_lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {

  function_name = var.lambda_function_name
  description   = "This Lambda function is used to rotate rds db user secrets"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "hello_lambda.lambda_handler"
  timeout       = 900

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  runtime = "python3.9"
  environment {

    variables = {
      SLACK_WEBHOOK_URL        = var.slack_url,
      SLACK_CHANNEL_NAME       = var.slack_channel,
      greeting                 = "sbx",
      SECRETS_MANAGER_ENDPOINT = ""
    }
  }
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [for items in aws_subnet.fleur-private-subnet[*] : items.id]
    security_group_ids = [aws_security_group.fleur-private-security-group.id, aws_security_group.fleur-public-security-group.id]
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name_prefix       = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name_prefix        = "iam_for_hqr_lambda"
  assume_role_policy = data.aws_iam_policy_document.policy.json
}
