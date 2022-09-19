locals {
  az            = lookup({ for az in data.openstack_compute_availability_zones_v2.zones.names : az => az }, local.configuration.availability_zone)
  jump_host_fip = data.openstack_compute_instance_v2.jump_host.access_ip_v4
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

data "openstack_compute_instance_v2" "jump_host" {
  id = local.configuration.jump_host
}

# Workaround to fail if jump_host (id) is not valid, as the data source does not
# throw an error if it does not exist
data "openstack_networking_floatingip_v2" "jump_host_fip" {
  fixed_ip = local.jump_host_fip != null ? local.jump_host_fip : "jump-host-not-found"
}

