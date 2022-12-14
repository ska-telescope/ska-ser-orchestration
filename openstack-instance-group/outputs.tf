output "instance_group" {
  description = "Instance group instances state"
  value = {
    instances = { for instance in module.instance : instance.instance.name => instance.instance }
  }
}

output "inventory" {
  description = "Instance group ansible inventory"
  value       = local.inventory
}