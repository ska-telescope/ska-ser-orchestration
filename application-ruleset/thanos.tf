locals {
  thanos_rules = {
    thanos_querier_ingress = {
      service   = "thanos_querier"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9091]
      target    = "network"
    }
    thanos_frontend_ingress = {
      service   = "thanos_frontend"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9095]
      target    = "network"
    }
  }
}