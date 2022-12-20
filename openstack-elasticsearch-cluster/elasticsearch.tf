module "elasticsearch_master" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("-", [local.elasticsearch.name, local.elasticsearch.master.name])
    size              = local.elasticsearch.master.size
    flavor            = local.elasticsearch.master.flavor
    image             = local.elasticsearch.master.image
    availability_zone = local.elasticsearch.master.availability_zone
    network           = local.elasticsearch.master.network
    security_groups   = []
    keypair           = local.elasticsearch.master.keypair
    jump_host         = local.elasticsearch.master.jump_host
    volumes = [
      {
        name        = "data"
        size        = local.elasticsearch.master.data_volume_size
        mount_point = "/var/lib/stack-data"
      },
      {
        name        = "docker"
        size        = local.elasticsearch.master.docker_volume_size
        mount_point = "/var/lib/docker"
      },
    ]
    applications = distinct(flatten([for role in local.elasticsearch.master.roles : local.role_applications[role]]))
    metadata = {
      roles = join(",", local.elasticsearch.master.roles)
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
    name              = join("-", [local.elasticsearch.name, local.elasticsearch.data.name])
    size              = local.elasticsearch.data.size
    flavor            = local.elasticsearch.data.flavor
    image             = local.elasticsearch.data.image
    availability_zone = local.elasticsearch.data.availability_zone
    network           = local.elasticsearch.data.network
    security_groups   = []
    keypair           = local.elasticsearch.data.keypair
    jump_host         = local.elasticsearch.data.jump_host
    volumes = [
      {
        name        = "data"
        size        = local.elasticsearch.data.data_volume_size
        mount_point = "/var/lib/stack-data"
      },
      {
        name        = "docker"
        size        = local.elasticsearch.data.docker_volume_size
        mount_point = "/var/lib/docker"
      },
    ]
    applications = distinct(flatten([for role in local.elasticsearch.data.roles : local.role_applications[role]]))
    metadata = {
      roles = join(",", local.elasticsearch.data.roles)
    }
  }
}