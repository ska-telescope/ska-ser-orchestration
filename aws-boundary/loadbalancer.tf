locals {
  loadbalancer = {
    name                       = coalesce(var.boundary.loadbalancer.name, var.defaults.loadbalancer.name)
    environment                = coalesce(var.boundary.loadbalancer.environment, var.defaults.loadbalancer.environment)
    internal                   = coalesce(var.boundary.loadbalancer.internal, var.defaults.loadbalancer.internal)
    load_balancer_type         = coalesce(var.boundary.loadbalancer.load_balancer_type, var.defaults.loadbalancer.load_balancer_type)
    security_groups            = coalescelist(var.boundary.loadbalancer.security_groups, var.defaults.loadbalancer.security_groups)
    subnets                    = coalescelist(var.boundary.loadbalancer.subnets, var.defaults.loadbalancer.subnets)
    enable_deletion_protection = coalesce(var.boundary.loadbalancer.enable_deletion_protection, var.defaults.loadbalancer.enable_deletion_protection)
  }
}

resource "aws_lb" "lb" {
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

