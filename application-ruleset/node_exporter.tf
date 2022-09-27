locals {
  node_exporter_rules = {
    node_exporter_ingress = {
      service   = "node_exporter"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9100]
      target    = "network"
      scrape    = true
    }
  }
}