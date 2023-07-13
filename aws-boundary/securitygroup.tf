locals {
  securitygroup = {
    controller_subnet_id = coalesce(var.boundary.controller.subnet_id, var.defaults.controller.subnet_id)
    worker_subnet_id = coalesce(var.boundary.worker.subnet_id, var.defaults.worker.subnet_id) 
  }
}
data "aws_subnet" "controllers" {
  id = local.securitygroup.controller_subnet_id
}

data "aws_subnet" "workers" {
  id = local.securitygroup.worker_subnet_id
}

data "aws_lb" "loadbalancer" {
  name = local.loadbalancer.name
}

resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow Postgres inbound traffic"
  vpc_id      = data.aws_subnet.controllers.vpc_id

  ingress {
    description = "Postgres from Controller"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.controllers.cidr_block]
  }

  tags = {
    Name = "allow_postgres"
  }
}

resource "aws_security_group" "allow_controller_inbound" {
  name        = "allow_controller_inbound"
  description = "Allow Controller inbound traffic"
  vpc_id      = data.aws_subnet.controllers.vpc_id

  ingress {
    description     = "Traffic from Loadbalancer"
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = data.aws_lb.loadbalancer.security_groups
  }

  tags = {
    Name = "allow_controller_inbound"
  }
}

resource "aws_security_group" "allow_worker_inbound" {
  name        = "allow_worker_inbound"
  description = "Allow Worker inbound traffic"
  vpc_id      = data.aws_subnet.workers.vpc_id

  ingress {
    description = "Traffic from Controllers"
    from_port   = 9202
    to_port     = 9202
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.controllers.cidr_block]
  }

  tags = {
    Name = "allow_worker_inbound"
  }
}

resource "aws_security_group" "allow_external_https" {
  name        = "allow_external_https"
  description = "Allow HTTPS external inbound traffic"

  ingress {
    description = "HTTPS from External"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_external_https"
  }
}