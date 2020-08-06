locals {
  blue_target_group_name = "${var.name}TargetGroupBlue"
  green_target_group_name = "${var.name}TargetGroupGreen"
}

# Create application load balancer
resource "aws_lb" "application" {
  name = var.name
  internal = false
  load_balancer_type = "application"
  enable_deletion_protection = var.enable_deletion_protection
  security_groups = var.security_group_ids
  subnets = var.subnet_ids

  access_logs {
    bucket = var.log_bucket
    prefix = var.name
    enabled = true
  }

  tags = merge(var.tags, {
    Name = var.name
    LogBucketName = var.log_bucket
    GreenTargetGroupName = local.green_target_group_name
    BlueTargetGroupName = local.blue_target_group_name
  })
}

# Create blue target group
resource "aws_lb_target_group" "blue" {
  name = local.blue_target_group_name
  port = var.target_port
  protocol = var.target_protocol
  target_type = "ip"
  vpc_id = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path = var.health_check_url
    port = var.health_check_port
    matcher = var.health_check_response_codes
    timeout = var.health_check_timeout
    protocol = var.health_check_protocol
  }

  tags = merge(var.tags, {
    Name = local.blue_target_group_name
    ApplicationLoadBalancerName = var.name
  })
}

# Create green target group
resource "aws_lb_target_group" "green" {
  name = local.green_target_group_name
  port = var.target_port
  protocol = var.target_protocol
  target_type = var.target_type
  vpc_id = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path = var.health_check_url
    port = var.health_check_port
    matcher = var.health_check_response_codes
    timeout = var.health_check_timeout
    protocol = var.health_check_protocol
  }

  tags = merge(var.tags, {
    Name = local.green_target_group_name
    ApplicationLoadBalancerName = var.name
  })
}

# Create listener
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application.arn
  port = var.listener_port
  protocol = var.listener_protocol
  certificate_arn = var.listener_certificate_arn
  ssl_policy = var.listener_ssl_policy

  # Default action will forward to the green target group
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.green.arn
  }
}