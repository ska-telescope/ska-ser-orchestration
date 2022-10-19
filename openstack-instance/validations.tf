locals {
  az                  = lookup({ for az in data.openstack_compute_availability_zones_v2.zones.names : az => az }, local.configuration.availability_zone)
  jump_host           = length(keys(data.external.jump_host.result)) > 0 ? data.external.jump_host.result : null
  jump_host_addresses = local.jump_host != null ? split(",", data.external.jump_host.result.addresses) : []
}

data "openstack_compute_flavor_v2" "flavor" {
  name = local.configuration.flavor
}

data "openstack_images_image_v2" "image" {
  name        = local.configuration.image
  most_recent = true
}

data "openstack_compute_availability_zones_v2" "zones" {
}

data "openstack_networking_network_v2" "network" {
  name = local.configuration.network
}

data "openstack_compute_keypair_v2" "keypair" {
  name = local.configuration.keypair
}

data "external" "jump_host" {
  program = [var.python, "${path.module}/scripts/get_instance_by_id.py"]
  query = {
    id = local.configuration.jump_host
  }
}
