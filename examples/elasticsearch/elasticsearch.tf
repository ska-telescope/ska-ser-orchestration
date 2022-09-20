locals {
  elasticsearch_name = "elasticsearch_${random_string.random.result}"
}

resource "random_string" "random" {
  length  = 4
  special = false
}

module "elasticsearch" {
  source   = "../../openstack-elasticsearch-cluster"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  elasticsearch = {
    name = local.elasticsearch_name
    master = {
      size             = 1
      data_volume_size = 10
    }
    data = {
      flavor           = "m1.large"
      size             = 3
      data_volume_size = 20
    }
    kibana = {}
  }
}