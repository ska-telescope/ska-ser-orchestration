locals {
  haproxy_rules = {
    stats_ingress = {
      service   = "haproxy"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9090]
      target    = "public"
    }
  }
  haproxy_elasticsearch_rules = {
    haproxy_elasticsearch_api_ingress = {
      service   = "elasticsearch"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9200]
      target    = "public"
    }
  }
}