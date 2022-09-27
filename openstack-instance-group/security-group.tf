locals {
  jump_hosts = compact(distinct(flatten([
    for instance in module.instance : [
      for ip in instance.instance.ssh.jump_host.interfaces : "${ip}/32"
    ]
  ])))
  ssh_cidr_blocks = [
    for jump_host in local.jump_hosts : {
      cidr        = jump_host
      description = "Jump host access"
    }
  ]
}

resource "openstack_networking_secgroup_v2" "instance_group_security_group" {
  name        = "${local.configuration.name}-sg"
  description = "${local.configuration.name} security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_sg_rule" {
  for_each          = { for cidr_block in local.ssh_cidr_blocks : cidr_block.cidr => cidr_block.description... }
  security_group_id = openstack_networking_secgroup_v2.instance_group_security_group.id
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
  applications = local.configuration.applications
  networks     = [local.configuration.network]
  providers = {
    openstack = openstack
  }
}

resource "openstack_networking_secgroup_rule_v2" "sg_rule" {
  for_each          = module.applications_ruleset.ruleset
  security_group_id = openstack_networking_secgroup_v2.instance_group_security_group.id
  direction         = each.value.direction
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  remote_ip_prefix  = each.value.remote_ip_prefix
  description       = each.value.description
}