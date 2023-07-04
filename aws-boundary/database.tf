locals {
    allocated_storage    = coalesce(var.boundary.database.allocated_storage, var.defaults.database.allocated_storage)
    db_name              = coalesce(var.boundary.database.db_name, var.defaults.database.db_name)
    engine               = coalesce(var.boundary.database.engine, var.defaults.database.engine)
    engine_version       = coalesce(var.boundary.database.engine_version, var.defaults.database.engine_version)
    instance_class       = coalesce(var.boundary.database.instance_class, var.defaults.database.instance_class)
    username             = coalesce(var.boundary.database.username, var.defaults.database.username)
    password             = coalesce(var.boundary.database.password, var.defaults.database.password)
    parameter_group_name = coalesce(var.boundary.database.parameter_group_name, var.defaults.database.parameter_group_name)
    skip_final_snapshot  = coalesce(var.boundary.database.skip_final_snapshot, var.defaults.database.skip_final_snapshot)
}

resource "aws_db_instance" "default" {
allocated_storage    = local.allocated_storage
db_name              = local.db_name
engine               = local.engine
engine_version       = local.engine_version
instance_class       = local.instance_class
username             = local.username
password             = local.password
parameter_group_name = local.parameter_group_name
skip_final_snapshot  = local.skip_final_snapshot
} 
