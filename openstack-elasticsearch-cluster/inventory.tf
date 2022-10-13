locals {
  inventory = {
    (local.elasticsearch.name) = {
      children = merge([
        module.elasticsearch_master.inventory,
        module.elasticsearch_data.inventory,
        module.kibana.inventory
      ]...)
      hosts = merge([
        local.elasticsearch.loadbalancer.deploy ? module.loadbalancer[0].inventory : null
      ]...)
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