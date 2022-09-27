locals {
  subnet_ids = toset(distinct(flatten([
    for subnet in merge(data.openstack_networking_network_v2.network.*...) :
    subnet.subnets
  ])))
  subnets = { for subnet in data.openstack_networking_subnet_v2.subnet : subnet.name => subnet.cidr }
}

data "openstack_networking_network_v2" "network" {
  for_each = toset(var.networks)
  name     = each.value
}

data "openstack_networking_subnet_v2" "subnet" {
  for_each  = local.subnet_ids
  subnet_id = each.value
}