locals {
  reverseproxy_rules = {
    reverseproxy_ingress = {
      service   = "reverseproxy"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [80, 443]
      target    = "public"
    }
    reverseproxy_k8s_haproxy = {
      service   = "reverseproxy"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [9443, 6443]
      target    = "public"
    }
    reverseproxy_thanos_sidecar = {
      service   = "reverseproxy"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [10901]
      target    = "network"
    }
  }
}