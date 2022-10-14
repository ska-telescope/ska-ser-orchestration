locals {
  default_fip_network = coalesce(var.defaults.floating_ip_network, "External")
  fip_configuration = {
    create  = local.configuration.floating_ip != null ? coalesce(local.configuration.floating_ip.create, false) : false
    network = local.configuration.floating_ip != null ? coalesce(local.configuration.floating_ip.network, local.default_fip_network) : local.default_fip_network
    address = local.configuration.floating_ip != null ? local.configuration.floating_ip.address != null ? local.configuration.floating_ip.address : "" : ""
  }

  ipv4_regex             = "(^$|^^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$)"
  valid_ip_configuration = regex(local.ipv4_regex, local.fip_configuration.address)
  valid_ipv4_address     = length(local.valid_ip_configuration[0]) > 0

  associate_fip = local.fip_configuration.create || local.valid_ipv4_address
  set_fip       = local.fip_configuration.create && local.valid_ipv4_address
  floating_ip   = local.fip_configuration.create ? openstack_networking_floatingip_v2.floating_ip[0].address : local.fip_configuration.address == "" ? null : data.openstack_networking_floatingip_v2.floating_ip[0].address
}

data "openstack_networking_floatingip_v2" "floating_ip" {
  count   = !local.fip_configuration.create && local.associate_fip ? 1 : 0
  address = local.fip_configuration.address
}

data "openstack_networking_network_v2" "floating_ip_network" {
  count = local.fip_configuration.create && local.associate_fip ? 1 : 0
  name  = local.fip_configuration.network
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  count      = local.fip_configuration.create && local.associate_fip ? 1 : 0
  address    = local.set_fip ? local.configuration.floating_ip.address : null
  pool       = local.fip_configuration.network
  subnet_ids = data.openstack_networking_network_v2.floating_ip_network[0].subnets
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  count                 = local.associate_fip ? 1 : 0
  floating_ip           = local.floating_ip
  instance_id           = openstack_compute_instance_v2.instance.id
  fixed_ip              = openstack_compute_instance_v2.instance.access_ip_v4
  wait_until_associated = true
}