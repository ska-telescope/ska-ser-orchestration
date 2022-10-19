locals {
  inventory = {
    (local.ceph.name) = {
      children = merge([
        module.ceph_master.inventory,
        module.ceph_worker.inventory
      ]...)
      hosts = {}
    }
  }
}

# Null resource to store the inventory in the state without an output
resource "null_resource" "inventory" {
  triggers = {
    type      = "cluster"
    inventory = base64encode(jsonencode(local.inventory))
  }
}