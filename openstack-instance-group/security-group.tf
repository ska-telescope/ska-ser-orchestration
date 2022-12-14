locals {
  empty_group_rules   = {}
  security_group_name = local.configuration.size == 0 ? null : openstack_networking_secgroup_v2.instance_group_security_group[0].name
  security_group_id   = local.configuration.size == 0 ? null : openstack_networking_secgroup_v2.instance_group_security_group[0].id
  ssh_cidr_blocks = merge([
    for instance in module.instance : instance.instance.ssh_cidr_blocks
  ]...)
}

resource "openstack_networking_secgroup_v2" "instance_group_security_group" {
  count       = local.configuration.size > 0 ? 1 : 0
  name        = "${local.configuration.name}-sg"
  description = "${local.configuration.name} security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_sg_rule" {
  for_each          = local.configuration.size == 0 ? local.empty_group_rules : local.ssh_cidr_blocks
  security_group_id = local.security_group_id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.key
  description       = try(join("\n", each.value), each.value)
}

module "applications_ruleset" {
  source       = "../application-ruleset"
  applications = concat(local.configuration.applications, ["default"])
  networks     = [local.configuration.network]
  providers = {
    openstack = openstack
  }
}

resource "openstack_networking_secgroup_rule_v2" "sg_rule" {
  for_each          = local.configuration.size == 0 ? local.empty_group_rules : module.applications_ruleset.ruleset
  security_group_id = local.security_group_id
  direction         = each.value.direction
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  description       = each.value.description
}