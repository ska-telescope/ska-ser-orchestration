locals {
  ssh_cidr_blocks = local.configuration.create_security_group ? [
    {
      cidr        = "${data.openstack_networking_floatingip_v2.jump_host_fip.address}/32"
      description = "Jump-host access"
    },
    {
      cidr        = "${data.openstack_networking_floatingip_v2.jump_host_fip.fixed_ip}/32"
      description = "Jump-host access"
    }
  ] : []
  instance_security_group = local.configuration.create_security_group ? openstack_networking_secgroup_v2.instance_security_group.*.name : []
}

resource "openstack_networking_secgroup_v2" "instance_security_group" {
  count       = local.configuration.create_security_group ? 1 : 0
  name        = "${local.configuration.name}-sg"
  description = "${local.configuration.name} security group"
}

resource "openstack_networking_secgroup_rule_v2" "ssh_sg_rule" {
  for_each          = { for cidr_block in local.ssh_cidr_blocks : cidr_block.cidr => cidr_block.description... }
  security_group_id = openstack_networking_secgroup_v2.instance_security_group[0].id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.key
  description       = try(join("\n", each.value), each.value)
}