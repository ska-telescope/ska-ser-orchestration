locals {
  nexus_rules = {
    nexus_http_ingress = {
      service   = "nexus_http_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [8081]
      target    = "network"
    },
    nexus_docker_ingress = {
      service   = "nexus_docker_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9080, 9081, 9082, 9083, 9084]
      target    = "public"
    }
  }
}