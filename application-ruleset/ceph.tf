locals {
  ceph_rules = {
    ceph_ingress = {
      service   = "ceph"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [22]
      target    = "network"
    }
  }
}