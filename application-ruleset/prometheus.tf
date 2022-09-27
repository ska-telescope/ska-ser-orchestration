locals {
  prometheus_rules = {
    prometheus_ingress = {
      service   = "prometheus"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9090]
      target    = "network"
    }
    altertmanager_ingress = {
      service   = "alertmanager"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9093]
      target    = "network"
    }
  }
}