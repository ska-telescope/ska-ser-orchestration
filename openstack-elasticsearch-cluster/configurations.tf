locals {
  elasticsearch = defaults(var.elasticsearch, {
    name = "elasticsearch"
    master = {
      name             = "master"
      size             = 3
      data_volume_size = 20
    }
    data = {
      name             = "data"
      size             = 5
      data_volume_size = 250
    }
    kibana = {
      name = "kibana"
      size = 1
    }
  })
}