locals {
  az                    = lookup({ for az in data.openstack_compute_availability_zones_v2.zones.names : az => az }, local.configuration.availability_zone)
  jump_host             = length(keys(data.external.jump_host.result)) > 0 ? data.external.jump_host.result : null
  jump_host_addresses   = local.jump_host != null ? split(",", data.external.jump_host.result.addresses) : []
  skip_image_validation = length(regexall("^\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}$", local.configuration.image)) > 0
  image = {
    id   = local.skip_image_validation ? local.configuration.image : data.openstack_images_image_v2.image[0].id
    name = local.configuration.image
  }
}

data "openstack_networking_secgroup_v2" "external_sgs" {
  for_each = toset(local.configuration.external_security_groups)
  name     = each.value
}

data "openstack_compute_flavor_v2" "flavor" {
  name = local.configuration.flavor
}

data "openstack_images_image_v2" "image" {
  count       = local.skip_image_validation ? 0 : 1
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
