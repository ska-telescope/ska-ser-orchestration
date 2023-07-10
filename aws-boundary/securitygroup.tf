locals {
    securitygroup = {
        controller_subnet_id = coalesce(var.boundary.controller.subnet_id, var.defaults.controller.subnet_id)
    }
}
data "aws_subnet" "controller" {
  id = local.securitygroup.controller_subnet_id
}

resource "aws_security_group" "allow_postgres" {
  name        = "allow_postgres"
  description = "Allow Postgres inbound traffic"
  vpc_id      = data.aws_subnet.controller.vpc_id

  ingress {
    description = "Postgres from Controller"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.controller.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_postgres"
  }
}

resource "aws_security_group" "allow_external_https" {
  name        = "allow_external_https"
  description = "Allow Postgres inbound traffic"
  vpc_id      = data.aws_subnet.controller.vpc_id

  ingress {
    description = "HTTPS from External"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.controller.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_https"
  }
}