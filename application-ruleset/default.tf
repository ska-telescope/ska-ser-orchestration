locals {
  default_rules = {
    icmp_ingress = {
      service   = "icmp"
      direction = "ingress"
      protocol  = "icmp"
      target    = "public"
    }
  }
}