locals {
    kms = {
        name                = coalesce(var.boundary.kms.name, var.defaults.kms.name)
        master_key_spec     = coalesce(var.boundary.kms.master_key_spec, var.defaults.kms.master_key_spec)
        is_enabled          = coalesce(var.boundary.kms.is_enabled, var.defaults.kms.is_enabled)
        enable_key_rotation = coalesce(var.boundary.kms.enable_key_rotation, var.defaults.kms.enable_key_rotation)
    }
}


resource "aws_kms_key" "kms_key" {
  description              = "KMS Keys for Boundary Data Encryption"
  customer_master_key_spec = local.kms.master_key_spec
  is_enabled               = local.kms.is_enabled
  enable_key_rotation      = local.kms.enable_key_rotation

  tags = {
    Name = local.kms.name
  }

}

