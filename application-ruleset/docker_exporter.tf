locals {
  docker_exporter_rules = {
    docker_exporter_ingress = {
      service   = "docker_exporter"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9323]
      target    = "network"
      scrape    = true
    }
  }
}