locals {
  kibana_rules = {
    kibana_ingress = {
      service   = "kibana"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [5601]
      target    = "network"
    }
  }
}