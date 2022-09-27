module "kibana" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("_", [local.elasticsearch.name, local.elasticsearch.kibana.name])
    size              = local.elasticsearch.kibana.size
    flavor            = local.elasticsearch.kibana.flavor
    image             = local.elasticsearch.kibana.image
    availability_zone = local.elasticsearch.kibana.availability_zone
    network           = local.elasticsearch.kibana.network
    security_groups   = []
    keypair           = local.elasticsearch.kibana.keypair
    jump_host         = local.elasticsearch.kibana.jump_host
    volumes = [
      {
        name        = "docker"
        size        = local.elasticsearch.kibana.docker_volume_size
        mount_point = "/var/lib/docker"
      }
    ]
    applications = ["kibana", "node_exporter"]
  }
}