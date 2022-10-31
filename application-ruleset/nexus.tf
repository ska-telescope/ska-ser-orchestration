locals {
  nexus_rules = {
    nexus_ssh_ingress = {
      service   = "nexus_ssh_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [22]
      target    = "network"
    },
    nexus_http_ingress = {
      service   = "nexus_http_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [8081]
      target    = "network"
    },
    nexus_docker_hosted_ingress = {
      service   = "nexus_docker_hosted_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9080]
      target    = "network"
    },
    nexus_docker_proxy_ingress = {
      service   = "nexus_docker_proxy_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9081]
      target    = "network"
    },
    nexus_docker_group_ingress = {
      service   = "nexus_docker_group_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9082]
      target    = "network"
    },
    nexus_docker_quarantine_ingress = {
      service   = "nexus_docker_quarantine_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9083]
      target    = "network"
    },
    nexus_central_hosted_ingress = {
      service   = "nexus_central_hosted_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9084]
      target    = "network"
    }
  }
}