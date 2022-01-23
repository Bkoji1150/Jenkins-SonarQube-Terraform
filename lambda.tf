
resource "aws_lambda_function" "test_lambda" {
  filename      = "my-deployment-package.zip"
  function_name = var.lambda_function_name
  description   = "This Lambda function is used to rotate rds db user secrets"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 900

  source_code_hash = filebase64sha256("my-deployment-package.zip")

  runtime = "python3.9"


  environment {

    variables = {
      SLACK_WEBHOOK_URL  = var.slack_url,
      SLACK_CHANNEL_NAME = var.slack_channel
    }
  }
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [for items in aws_subnet.fleur-private-subnet[*] : items.id]
    security_group_ids = [aws_security_group.fleur-private-security-group.id, aws_security_group.fleur-public-security-group.id]
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
          "application-autoscaling:*",
          "autoscaling:*",
          "apigateway:*",
          "cloudfront:*",
          "cloudwatch:*",
          "cloudformation:*",
          "dax:*",
          "dynamodb:*",
          "ec2:*",
          "ec2messages:*",
          "ecr:*",
          "ecs:*",
          "elasticfilesystem:*",
          "elasticache:*",
          "elasticloadbalancing:*",
          "es:*",
          "events:*",
          "iam:*",
          "kms:*",
          "lambda:*",
          "logs:*",
          "rds:*",
          "route53:*",
          "ssm:*",
          "ssmmessages:*",
          "s3:*",
          "sns:*",
          "sqs:*",
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
