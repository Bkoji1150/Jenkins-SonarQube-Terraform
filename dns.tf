
# CREATE ALB 
resource "aws_security_group" "lb" {

  description = "Allow access to Application Load Balancer"
  name        = "${var.component_name}-alb-SG"
  vpc_id      = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = var.container_port
    to_port     = var.container_port
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "alb" {

  name               = "${var.component_name}-alb"
  load_balancer_type = "application"
  subnets            = local.public_subnet
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_listener" "api" {

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "api_https" {

  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb_target_group" "api" {
  name        = "${var.component_name}-api"
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"
  port        = var.container_port

  health_check {
    path = var.target_group_health_check_path
  }
  lifecycle {
    ignore_changes        = [name] # this this to prevent our target group no to get destroyed
    create_before_destroy = true
  }
}

data "aws_route53_zone" "zone" {
  name = "${var.dns_zone_name}."
}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "3.0.0"

  domain_name               = trimsuffix(data.aws_route53_zone.zone.name, ".")
  zone_id                   = data.aws_route53_zone.zone.zone_id
  subject_alternative_names = var.subject_alternative_names
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.dns_zone_name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "app_public_files" {
  bucket        = lower("${var.component_name}-${var.cell_name}-files")
  acl           = "public-read"
  force_destroy = true
}


resource "aws_iam_role" "app_iam_role" {
  name               = "${var.component_name}-api-task"
  assume_role_policy = file("./templates/assume-role-policy.json")

}

data "template_file" "ecs_s3_write_policy" {
  template = file("./templates/s3-write-policy.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.app_public_files.arn
  }
}

resource "aws_iam_policy" "ecs_s3_access" {
  name        = "${var.component_name}-AppS3AccessPolicy"
  path        = "/"
  description = "Allow access to the recipe app S3 bucket"

  policy = data.template_file.ecs_s3_write_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_s3_access" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = aws_iam_policy.ecs_s3_access.arn
}
