locals {
  user       = "ubuntu" # TODO: Get from image metadata
  port_sufix = substr(data.openstack_networking_network_v2.network.id, 0, 4)
}

resource "openstack_networking_port_v2" "network_port" {
  name                  = "${local.configuration.name}-${local.port_sufix}"
  network_id            = data.openstack_networking_network_v2.network.id
  port_security_enabled = local.configuration.port_security_enabled
}

resource "openstack_compute_instance_v2" "instance" {
  name                = local.configuration.name
  flavor_name         = data.openstack_compute_flavor_v2.flavor.name
  availability_zone   = local.az
  image_id            = local.image.id
  key_pair            = data.openstack_compute_keypair_v2.keypair.name
  security_groups     = concat(local.configuration.security_groups, local.instance_security_group)
  stop_before_destroy = true
  metadata            = local.configuration.metadata

  network {
    uuid = data.openstack_networking_network_v2.network.id
    # port = openstack_networking_port_v2.network_port.id
    # TODO: Uncomment port assignment when migration steps are available
    # as part of https://jira.skatelescope.org/browse/ST-1491
  }

  block_device {
    uuid             = local.image.id
    source_type      = "image"
    destination_type = "local"
    boot_index       = 0
  }
}
