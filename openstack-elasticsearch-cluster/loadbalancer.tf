locals {
  floating_ip_configuration = var.elasticsearch.loadbalancer.floating_ip != null ? var.elasticsearch.loadbalancer.floating_ip : {
    create  = true
    network = null
    address = null
  }
}

module "loadbalancer" {
  source   = "../openstack-instance"
  count    = var.elasticsearch.loadbalancer.deploy ? 1 : 0
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("-", [var.elasticsearch.name, var.elasticsearch.loadbalancer.name])
    flavor            = var.elasticsearch.loadbalancer.flavor
    image             = var.elasticsearch.loadbalancer.image
    availability_zone = var.elasticsearch.loadbalancer.availability_zone
    network           = var.elasticsearch.loadbalancer.network
    security_groups   = []
    keypair           = var.elasticsearch.loadbalancer.keypair
    jump_host         = var.elasticsearch.loadbalancer.jump_host
    volumes = [
      {
        name        = "docker"
        size        = var.elasticsearch.loadbalancer.docker_volume_size
        mount_point = "/var/lib/docker"
      }
    ]
    applications = local.role_applications["loadbalancer"]
    metadata = {
      roles = join(",", ["loadbalancer"])
    }
    floating_ip = {
      create  = coalesce(local.floating_ip_configuration.create, true)
      network = local.floating_ip_configuration.network
      address = local.floating_ip_configuration.address
    }
  }
}