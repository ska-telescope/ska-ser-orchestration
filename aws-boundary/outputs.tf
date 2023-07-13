output "boundary" {
  description = "Boundary instance groups states"
  value = {
    instance_groups = {
      controller = module.boundary_controller.instance
    }
  }
}