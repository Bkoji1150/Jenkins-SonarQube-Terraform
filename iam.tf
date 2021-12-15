
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
      "*"
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
      "*"
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


data "aws_iam_policy_document" "jenkins_agent_policy" {
  statement {
    sid       = "AllowSpecifics"
    effect    = "Allow"
    resources = [aws_instance.SonarQubesinstance.arn]
    actions = [
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
    ]

  }

  statement {
    sid       = "DenySpecifics"
    effect    = "Deny"
    resources = ["*"]
    actions = [
      "aws-marketplace-management:*",
      "aws-marketplace:*",
      "aws-portal:*",
      "budgets:*",
      "config:*",
      "directconnect:*",
      "ec2:*ReservedInstances*",
      "iam:*Group*",
      "iam:*Login*",
      "iam:*Provider*",
      "iam:*User*",
    ]
  }
}

resource "aws_iam_policy" "jenkins_agent_role" {
  name   = "Jenkins_agents_admin_role"
  path   = "/"
  policy = data.aws_iam_policy_document.jenkins_agent_policy.json
}

# resource "aws_iam_instance_profile" "jenkins_agent_instance" {
#     name = "jenkins_agent_instance"
#     role = "${aws_iam_policy.jenkins_agent_role.name}"
# }
