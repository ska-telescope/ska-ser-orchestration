locals {
  lb_rules = {
    http_ingress = {
      service   = "lb"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [80]
      target    = "public"
    }
    https_ingress = {
      service   = "lb"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [443]
      target    = "public"
    }
  }
  lb_elasticsearch_rules = {
    lb_api_ingress = {
      service   = "elasticsearch"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9200]
      target    = "public"
    }
  }
}