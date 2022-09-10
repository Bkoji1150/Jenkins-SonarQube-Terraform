resource "aws_iam_policy" "ecs" {
  name_prefix = format("%s-%s", var.component_name, "ecsRole")
  path        = "/"
  description = "IAM policy to allow ${var.component_name}-ecsRole have access"

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
