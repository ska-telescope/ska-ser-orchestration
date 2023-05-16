locals {
  dns_rules = {
    dns_tcp_port = {
      service   = "dns"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [53]
      target    = "public"
    },
    dns_udp_port = {
      service   = "dns"
      direction = "ingress"
      protocol  = "udp"
      ports     = [53]
      target    = "public"
    }
  }
}