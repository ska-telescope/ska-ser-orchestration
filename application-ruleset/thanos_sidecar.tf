locals {
  thanos_sidecar_rules = {
    thanos_sidecar_ingress = {
      service   = "thanos_sidecar"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [10901]
      target    = "network"
    }
  }
}