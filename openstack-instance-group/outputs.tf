output "instance_group" {
  description = "Instance group instances state"
  value = {
    instances = { for instance in module.instance : instance.instance.name => instance.instance }
  }
}

output "instance_group_inventory" {
  description = "Instance group ansible inventory"
  value = {
    "${local.configuration.name}" = merge([for instance in module.instance : instance.instance_inventory]...)
  }
}