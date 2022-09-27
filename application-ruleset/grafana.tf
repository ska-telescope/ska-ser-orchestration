locals {
  grafana_rules = {
    grafana_ingress = {
      service   = "grafana"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [3000]
      target    = "network"
    }
  }
}