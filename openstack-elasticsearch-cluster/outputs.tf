output "cluster" {
  description = "Cluster instance groups states"
  value = {
    name = var.elasticsearch.name
    instance_groups = {
      master = module.elasticsearch_master.instance_group.instances
      data   = module.elasticsearch_data.instance_group.instances
      kibana = module.kibana.instance_group.instances
    }
    instances = {
      loadbalancer = var.elasticsearch.loadbalancer.deploy ? module.loadbalancer[0].instance : null
    }
  }
}

output "inventory" {
  description = "Cluster ansible inventory"
  value       = local.inventory
}