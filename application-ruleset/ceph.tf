locals {
  ceph_rules = {
    ceph_ingress = {
      service   = "ssh"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [22]
      target    = "network"
    }
  }
}