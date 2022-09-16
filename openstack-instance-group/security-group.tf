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