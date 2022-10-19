output "cluster" {
  description = "Cluster instance groups states"
  value = {
    name = local.ceph.name
    instance_groups = {
      master = module.ceph_master.instance_group.instances
      worker   = module.ceph_worker.instance_group.instances
    }
  }
}

output "inventory" {
  description = "Cluster ansible inventory"
  value       = local.inventory
}