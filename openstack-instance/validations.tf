locals {
  az = lookup({ for az in data.openstack_compute_availability_zones_v2.zones.names : az => az }, local.configuration.availability_zone)
  # Workaround to validate the data query, as the provider implementation does not throw an error if it does not exist
  jump_host = coalesce(data.openstack_compute_instance_v2.jump_host.id, null)
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

# TODO: Move this to a generic module that can read information of various sources: openstack, aws, etc
data "openstack_compute_instance_v2" "jump_host" {
  id = local.configuration.jump_host
}

data "openstack_networking_floatingip_v2" "jump_host_fip" {
  fixed_ip = data.openstack_compute_instance_v2.jump_host.access_ip_v4
}

