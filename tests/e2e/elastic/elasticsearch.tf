module "elasticsearch" {
  source   = "../../../openstack-elasticsearch-cluster"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  elasticsearch = {
    name = "stfc-techops-e2e-logging"
    master = {
      size               = 1
      data_volume_size   = 10
      docker_volume_size = 10
    }
    data = {
      size               = 1
      data_volume_size   = 10
      docker_volume_size = 10
    }
    kibana = {
      size               = 0
      docker_volume_size = 10
    }
    loadbalancer = {
      deploy             = true
      docker_volume_size = 10
      floating_ip = {
        create = false
      }
    }
  }
}