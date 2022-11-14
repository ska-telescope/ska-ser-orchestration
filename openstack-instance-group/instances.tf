locals {
  instance_ids = [for instance_id in range(0, local.configuration.size) : format("i%02d", instance_id)]
  instance_configurations = {
    for instance_id in local.instance_ids :
    (instance_id) => {
      name                  = join("-", [local.configuration.name, instance_id])
      group                 = local.configuration.name
      flavor                = local.configuration.flavor
      image                 = local.configuration.image
      availability_zone     = local.configuration.availability_zone
      network               = local.configuration.network
      create_security_group = false
      security_groups       = distinct(concat(local.configuration.security_groups, compact([local.security_group_name])))
      keypair               = local.configuration.keypair
      jump_host             = local.configuration.jump_host
      volumes               = local.configuration.volumes
      applications          = local.configuration.applications
      metadata              = local.configuration.metadata
    }
  }
}

module "instance" {
  for_each = local.instance_configurations
  source   = "../openstack-instance"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = each.value
}
