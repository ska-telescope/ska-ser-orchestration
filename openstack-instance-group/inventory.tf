locals {
  inventory = {
    (local.configuration.name) = {
      hosts = merge([for instance in module.instance : instance.inventory]...)
    }
  }
}

# Null resource to store the inventory in the state without an output
resource "null_resource" "inventory" {
  triggers = {
    type      = "instance_group"
    inventory = base64encode(jsonencode(local.inventory))
  }
}