locals {
  user       = "ubuntu" # TODO: Get from image metadata
  port_sufix = substr(data.openstack_networking_network_v2.network.id, 0, 4)
}

resource "openstack_networking_port_v2" "network_port" {
  count                 = local.configuration.create_port ? 1 : 0
  name                  = "${local.configuration.name}-${local.port_sufix}"
  network_id            = data.openstack_networking_network_v2.network.id
  port_security_enabled = local.configuration.port_security_enabled
  security_group_ids    = local.configuration.port_security_enabled ? concat([for sg in data.openstack_networking_secgroup_v2.upstream_sg : sg.id], local.instance_security_group_ids) : null
}

resource "openstack_compute_instance_v2" "instance" {
  name                = local.configuration.name
  flavor_name         = data.openstack_compute_flavor_v2.flavor.name
  availability_zone   = local.az
  image_id            = local.image.id
  key_pair            = data.openstack_compute_keypair_v2.keypair.name
  security_groups     = local.configuration.create_port ? null : concat(local.configuration.security_groups, local.instance_security_group)
  stop_before_destroy = true
  metadata            = local.configuration.metadata

  network {
    uuid = data.openstack_networking_network_v2.network.id
    port = local.configuration.create_port ? openstack_networking_port_v2.network_port[0].id : null
  }

  block_device {
    uuid             = local.image.id
    source_type      = "image"
    destination_type = "local"
    boot_index       = 0
  }
}
