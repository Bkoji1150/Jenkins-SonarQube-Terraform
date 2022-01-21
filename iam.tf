data "aws_iam_policy_document" "policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstance",
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:DeleteInterface"
    ]

    resources = [
      aws_db_instance.postgres_rds.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage"
    ]

    resources = [
      aws_db_instance.postgres_rds.arn
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetRandomPassword"]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ec2_role" {
  name   = "RDS_Get_SecretsFromSecretsManager"
  path   = "/"
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_policy" "ec2_policy" {
  name        = "ec2_policy"
  path        = "/"
  description = "Policy to provide permission to EC2"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
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
          "sqs:*"
        ],
        "Resource" : concat([aws_instance.SonarQubesinstance.arn], [for i in aws_instance.jenkinsinstance[*] : i.arn])
      }
    ]
  })
}

# Create a role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "ec2_policy_role" {
  name       = "ec2_attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}
