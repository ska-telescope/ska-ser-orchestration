module "elasticsearch_master" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("-", [var.elasticsearch.name, var.elasticsearch.master.name])
    size              = var.elasticsearch.master.size
    flavor            = var.elasticsearch.master.flavor
    image             = var.elasticsearch.master.image
    availability_zone = var.elasticsearch.master.availability_zone
    network           = var.elasticsearch.master.network
    security_groups   = []
    keypair           = var.elasticsearch.master.keypair
    jump_host         = var.elasticsearch.master.jump_host
    volumes = [
      {
        name        = "data"
        size        = var.elasticsearch.master.data_volume_size
        mount_point = "/var/lib/stack-data"
      },
      {
        name        = "docker"
        size        = var.elasticsearch.master.docker_volume_size
        mount_point = "/var/lib/docker"
      },
    ]
    applications = distinct(flatten([for role in var.elasticsearch.master.roles : local.role_applications[role]]))
    metadata = {
      roles = join(",", var.elasticsearch.master.roles)
    }
  }
}

module "elasticsearch_data" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("-", [var.elasticsearch.name, var.elasticsearch.data.name])
    size              = var.elasticsearch.data.size
    flavor            = var.elasticsearch.data.flavor
    image             = var.elasticsearch.data.image
    availability_zone = var.elasticsearch.data.availability_zone
    network           = var.elasticsearch.data.network
    security_groups   = []
    keypair           = var.elasticsearch.data.keypair
    jump_host         = var.elasticsearch.data.jump_host
    volumes = [
      {
        name        = "data"
        size        = var.elasticsearch.data.data_volume_size
        mount_point = "/var/lib/stack-data"
      },
      {
        name        = "docker"
        size        = var.elasticsearch.data.docker_volume_size
        mount_point = "/var/lib/docker"
      },
    ]
    applications = distinct(flatten([for role in var.elasticsearch.data.roles : local.role_applications[role]]))
    metadata = {
      roles = join(",", var.elasticsearch.data.roles)
    }
  }
}