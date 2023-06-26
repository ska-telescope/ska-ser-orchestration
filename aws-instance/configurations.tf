locals {
  configuration = merge(var.configuration, {
    instance_type     = coalesce(var.configuration.instance_type, var.defaults.instance_type)
    ami               = coalesce(var.configuration.ami, var.defaults.ami)
    availability_zone = coalesce(var.configuration.availability_zone, var.defaults.availability_zone)
    subnet_id         = coalesce(var.configuration.subnet_id, var.defaults.subnet_id)
    keypair           = coalesce(var.configuration.keypair, var.defaults.keypair)
    jump_host         = try(coalesce(var.configuration.jump_host, var.defaults.jump_host), null)
  })
}