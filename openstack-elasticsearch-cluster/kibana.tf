module "kibana" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("-", [var.elasticsearch.name, var.elasticsearch.kibana.name])
    size              = var.elasticsearch.kibana.size
    flavor            = var.elasticsearch.kibana.flavor
    image             = var.elasticsearch.kibana.image
    availability_zone = var.elasticsearch.kibana.availability_zone
    network           = var.elasticsearch.kibana.network
    security_groups   = []
    keypair           = var.elasticsearch.kibana.keypair
    jump_host         = var.elasticsearch.kibana.jump_host
    volumes = [
      {
        name        = "docker"
        size        = var.elasticsearch.kibana.docker_volume_size
        mount_point = "/var/lib/docker"
      }
    ]
    applications = local.role_applications["kibana"]
    metadata = {
      roles = join(",", ["kibana"])
    }
  }
}