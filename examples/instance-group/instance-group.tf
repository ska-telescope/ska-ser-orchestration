locals {
  instance_group_name = "instance_group_${random_string.random.result}"
}

resource "random_string" "random" {
  length  = 4
  special = false
}

module "instance_group" {
  source   = "../../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name = local.instance_group_name
    size = 2
  }
}