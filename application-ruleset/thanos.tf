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
    thanos_store_ingress = {
      service   = "thanos_store"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [19090]
      target    = "network"
    }
    thanos_compactor_ingress = {
      service   = "thanos_compactor"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [19091]
      target    = "network"
    }
  }
}