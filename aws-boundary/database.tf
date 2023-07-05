locals {
  allocated_storage    = coalesce(var.boundary.database.allocated_storage, var.defaults.database.allocated_storage)
  db_name              = coalesce(var.boundary.database.db_name, var.defaults.database.db_name)
  db_subnet_group_name = coalesce(var.boundary.database.db_subnet_group_name, var.defaults.database.db_subnet_group_name)
  db_subnets           = coalescelist(var.boundary.database.db_subnets, var.defaults.database.db_subnets)
  controller_subnet_id = coalesce(var.boundary.controller.subnet_id, var.defaults.controller.subnet_id)
  engine               = coalesce(var.boundary.database.engine, var.defaults.database.engine)
  engine_version       = coalesce(var.boundary.database.engine_version, var.defaults.database.engine_version)
  instance_class       = coalesce(var.boundary.database.instance_class, var.defaults.database.instance_class)
  username             = coalesce(var.boundary.database.username, var.defaults.database.username)
  password             = coalesce(var.boundary.database.password, var.defaults.database.password)
  parameter_group_name = try(coalesce(var.boundary.database.parameter_group_name, var.defaults.database.parameter_group_name), null)
  skip_final_snapshot  = coalesce(var.boundary.database.skip_final_snapshot, var.defaults.database.skip_final_snapshot)
}

resource "aws_db_subnet_group" "data-subnet-group" {
  name       = "main"
  subnet_ids = local.db_subnets
}

data "aws_subnet" "controller" {
  id = local.controller_subnet_id
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

resource "aws_db_instance" "db_instance" {
  allocated_storage      = local.allocated_storage
  db_name                = local.db_name
  db_subnet_group_name   = local.db_subnet_group_name
  engine                 = local.engine
  engine_version         = local.engine_version
  instance_class         = local.instance_class
  username               = local.username
  password               = local.password
  parameter_group_name   = local.parameter_group_name
  skip_final_snapshot    = local.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.allow_postgres.id]

  depends_on = [aws_db_subnet_group.data-subnet-group,
  aws_security_group.allow_postgres]
}
