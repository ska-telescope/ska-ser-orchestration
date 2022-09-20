locals {
  inventory = {
    (local.elasticsearch.name) = {
      children = merge([
        module.elasticsearch_master.inventory,
        module.elasticsearch_data.inventory,
        module.kibana.inventory
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