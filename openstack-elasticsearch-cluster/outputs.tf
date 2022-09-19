output "cluster" {
  description = "Cluster instance groups states"
  value = {
    name = local.elasticsearch.name
    instance_groups = {
      master = module.elasticsearch_master.instance_group.instances
      data   = module.elasticsearch_data.instance_group.instances
      kibana = module.kibana.instance_group.instances
    }
  }
}

output "inventory" {
  description = "Cluster ansible inventory"
  value = {
    (local.elasticsearch.name) = {
      inventory_type = "cluster"
      children = merge([
        module.elasticsearch_master.inventory,
        module.elasticsearch_data.inventory,
        module.kibana.inventory
      ]...)
      hosts = {}
    }
  }
}