locals {
  loadbalancer = {
    name                       = coalesce(var.boundary.loadbalancer.name, var.defaults.loadbalancer.name)
    certificate_arn            = try(coalesce(var.boundary.loadbalancer.certificate_arn, var.defaults.loadbalancer.certificate_arn),null)
    environment                = coalesce(var.boundary.loadbalancer.environment, var.defaults.loadbalancer.environment)
    internal                   = coalesce(var.boundary.loadbalancer.internal, var.defaults.loadbalancer.internal)
    load_balancer_type         = coalesce(var.boundary.loadbalancer.load_balancer_type, var.defaults.loadbalancer.load_balancer_type)
    security_groups            = coalescelist(var.boundary.loadbalancer.security_groups, var.defaults.loadbalancer.security_groups)
    subnets                    = coalescelist(var.boundary.loadbalancer.subnets, var.defaults.loadbalancer.subnets)
    enable_deletion_protection = coalesce(var.boundary.loadbalancer.enable_deletion_protection, var.defaults.loadbalancer.enable_deletion_protection)
  }
}

resource "aws_lb" "loadbalancer" {
  name               = local.loadbalancer.name
  internal           = local.loadbalancer.internal
  load_balancer_type = local.loadbalancer.load_balancer_type
  security_groups    = local.loadbalancer.security_groups
  subnets            = local.loadbalancer.subnets
  enable_deletion_protection = local.loadbalancer.enable_deletion_protection

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = local.loadbalancer.environment
  }
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = local.loadbalancer.name

  tags = {
    Name        = local.loadbalancer.name
    Environment = local.loadbalancer.environment
  }
}

#resource "aws_lb_listener" "listener" {
#  load_balancer_arn = aws_lb.loadbalancer.arn
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = local.loadbalancer.certificate_arn

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.controller.arn
#  }
#}

resource "aws_lb_target_group" "controller" {
  name     = "controller"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = data.aws_subnet.controller.vpc_id
}

