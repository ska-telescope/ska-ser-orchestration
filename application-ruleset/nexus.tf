locals {
  nexus_rules = {
    nexus_haproxy_ingress = {
      service   = "nexus_haproxy_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9000, 8081, 8082]
      target    = "public"
    }
    nexus_http_ingress = {
      service   = "nexus_http_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [8881]
      target    = "network"
    },
    nexus_docker_ingress = {
      service    = "nexus_docker_ingress"
      direction  = "ingress"
      protocol   = "tcp"
      port_range = [9080, 9090]
      target     = "public"
    }
  }
}