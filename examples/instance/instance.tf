locals {
  instance_name = "instance_${random_string.random.result}"
}

resource "random_string" "random" {
  length  = 4
  special = false
}

module "instance" {
  source   = "../../openstack-instance"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name   = local.instance_name
    flavor = "m1.large"
    volumes = [
      {
        mount_point = "/home"
        name        = "home"
        size        = 30
      }
    ]
  }
}