locals {
  elasticsearch_rules = {
    elasticsearch_ingress = {
      service   = "elasticsearch"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9200, 9300]
      target    = "network"
    }
    elasticsearch_exporter_ingress = {
      service   = "elasticsearch_exporter"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9114]
      target    = "network"
      scrape    = true
    }
  }
}