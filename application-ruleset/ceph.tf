locals {
  ceph_rules = {
    ceph_ingress = {
      service   = "ceph_ssh_ingress"
      direction = "ingress"
      protocol  = "tcp"
      ports     = [22]
      target    = "network"
    }
  }
}