resource "aws_lb" "Project-Omegalb" {
  name               = "Project-Omegaloadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.public_sg
  subnets            = var.public_subnets
  idle_timeout       = 400
}

resource "aws_lb_target_group" "Project-OmegalbTargetGroup" {
  name     = "Project-Omegalb-${substr(uuid(), 0, 3)}"
  port     = var.tg_port     #80
  protocol = var.tg_portocol #"HTTP"
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes = [name] # this this to prevent our target group no to get destroyed
    create_before_destroy = true
    }
  health_check {
    healthy_threshold   = var.Project-Omega_healthy_threshold   # 2
    unhealthy_threshold = var.Project-Omega_unhealthy_threshold #2
    timeout             = var.lb_timeout                # 3
    interval            = var.lb_interval               # 30
  }
 }


 resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.Project-Omegalb.arn
  port              = var.listener_port     #80
  protocol          = var.listener_protocol #"HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Project-OmegalbTargetGroup.arn
  }
  }