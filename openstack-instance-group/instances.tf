locals {
  instance_ids = [for instance_id in range(0, local.configuration.size) : format("i%02d", instance_id)]
  instance_configurations = {
    for instance_id in local.instance_ids :
    "${instance_id}" => {
      name                  = join("_", [local.configuration.name, instance_id])
      group                 = local.configuration.name
      flavor                = local.configuration.flavor
      image                 = local.configuration.image
      availability_zone     = local.configuration.availability_zone
      network               = local.configuration.network
      create_security_group = false
      security_groups       = distinct(concat(local.configuration.security_groups, [openstack_networking_secgroup_v2.instance_group_security_group.name]))
      keypair               = local.configuration.keypair
      jump_host             = local.configuration.jump_host
      volumes               = local.configuration.volumes
    }
  }

  # Workaround to validate the data query, as the OpenStack provider implementation
  # does not throw an error if it does not exist
  jump_host = coalesce(data.openstack_compute_instance_v2.jump_host.id, null)
}

data "openstack_compute_instance_v2" "jump_host" {
  id = local.configuration.jump_host
}

data "openstack_networking_floatingip_v2" "jump_host_fip" {
  fixed_ip = data.openstack_compute_instance_v2.jump_host.access_ip_v4
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