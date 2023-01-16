locals {
  openvpn_rules = {
    openvpn_tcp_port = {
      service   = "openvpn"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [1194]
      target    = "public"
    },
    openvpn_udp_port = {
      service   = "openvpn"
      direction = "ingress"
      protocol  = "udp"
      ports     = [1194]
      target    = "public"
    }
  }
}