output "boundary" {
  description = "Boundary instance groups states"
  value = {
    instance_groups = {
      controller = module.boundary_controller.instance
    }
  }
}

output "kms_key_id" {
  value = aws_kms_key.kms_key.key_id
}

output "kms_key_arn" {
  value = aws_kms_key.kms_key.arn
}