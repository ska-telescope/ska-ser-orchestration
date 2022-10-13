locals {
  floating_ip_configuration = local.elasticsearch.loadbalancer.floating_ip != null ? local.elasticsearch.loadbalancer.floating_ip : {
    create  = true
    network = null
    address = null
  }
}

module "loadbalancer" {
  source   = "../openstack-instance"
  count    = local.elasticsearch.loadbalancer.deploy ? 1 : 0
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("-", [local.elasticsearch.name, local.elasticsearch.loadbalancer.name])
    flavor            = local.elasticsearch.loadbalancer.flavor
    image             = local.elasticsearch.loadbalancer.image
    availability_zone = local.elasticsearch.loadbalancer.availability_zone
    network           = local.elasticsearch.loadbalancer.network
    security_groups   = []
    keypair           = local.elasticsearch.loadbalancer.keypair
    jump_host         = local.elasticsearch.loadbalancer.jump_host
    volumes = [
      {
        name        = "docker"
        size        = local.elasticsearch.loadbalancer.docker_volume_size
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