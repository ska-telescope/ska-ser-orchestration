locals {
    database ={
        identifier           = coalesce(var.boundary.database.identifier, var.defaults.database.identifier)
        allocated_storage    = coalesce(var.boundary.database.allocated_storage, var.defaults.database.allocated_storage)
        db_name              = coalesce(var.boundary.database.db_name, var.defaults.database.db_name)
        db_subnet_group_name = coalesce(var.boundary.database.db_subnet_group_name, var.defaults.database.db_subnet_group_name)
        db_subnets           = coalescelist(var.boundary.database.db_subnets, var.defaults.database.db_subnets)
        engine               = coalesce(var.boundary.database.engine, var.defaults.database.engine)
        engine_version       = coalesce(var.boundary.database.engine_version, var.defaults.database.engine_version)
        instance_class       = coalesce(var.boundary.database.instance_class, var.defaults.database.instance_class)
        username             = coalesce(var.boundary.database.username, var.defaults.database.username)
        password             = coalesce(var.boundary.database.password, var.defaults.database.password)
        parameter_group_name = try(coalesce(var.boundary.database.parameter_group_name, var.defaults.database.parameter_group_name), null)
        skip_final_snapshot  = coalesce(var.boundary.database.skip_final_snapshot, var.defaults.database.skip_final_snapshot)
    }
}

resource "aws_db_subnet_group" "data-subnet-group" {
  name       = "main"
  subnet_ids = local.database.db_subnets
}

resource "aws_db_instance" "db_instance" {
  identifier             = local.database.identifier
  allocated_storage      = local.database.allocated_storage
  db_name                = local.database.db_name
  db_subnet_group_name   = local.database.db_subnet_group_name
  engine                 = local.database.engine
  engine_version         = local.database.engine_version
  instance_class         = local.database.instance_class
  username               = local.database.username
  password               = local.database.password
  parameter_group_name   = local.database.parameter_group_name
  skip_final_snapshot    = local.database.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.allow_postgres.id]

  depends_on = [aws_db_subnet_group.data-subnet-group,
  aws_security_group.allow_postgres]
}
