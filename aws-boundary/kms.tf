locals {
  kms = {
    root = {
        name                = coalesce(var.boundary.kms.root.name, var.defaults.kms.root.name)
        master_key_spec     = coalesce(var.boundary.kms.root.master_key_spec, var.defaults.kms.root.master_key_spec)
        is_enabled          = coalesce(var.boundary.kms.root.is_enabled, var.defaults.kms.root.is_enabled)
        enable_key_rotation = coalesce(var.boundary.kms.root.enable_key_rotation, var.defaults.kms.root.enable_key_rotation)
    }
    worker = {
        name                = coalesce(var.boundary.kms.worker.name, var.defaults.kms.worker.name)
        master_key_spec     = coalesce(var.boundary.kms.worker.master_key_spec, var.defaults.kms.worker.master_key_spec)
        is_enabled          = coalesce(var.boundary.kms.worker.is_enabled, var.defaults.kms.worker.is_enabled)
        enable_key_rotation = coalesce(var.boundary.kms.worker.enable_key_rotation, var.defaults.kms.worker.enable_key_rotation)
    }
    recovery = {
        name                = coalesce(var.boundary.kms.recovery.name, var.defaults.kms.recovery.name)
        master_key_spec     = coalesce(var.boundary.kms.recovery.master_key_spec, var.defaults.kms.recovery.master_key_spec)
        is_enabled          = coalesce(var.boundary.kms.recovery.is_enabled, var.defaults.kms.recovery.is_enabled)
        enable_key_rotation = coalesce(var.boundary.kms.recovery.enable_key_rotation, var.defaults.kms.recovery.enable_key_rotation)
    }
  }
}

resource "aws_kms_key" "root_kms_key" {
  description              = "Root Boundary KMS Key"
  customer_master_key_spec = local.kms.root.master_key_spec
  is_enabled               = local.kms.root.is_enabled
  enable_key_rotation      = local.kms.root.enable_key_rotation

  tags = {
    Name = local.kms.root.name
  }

}

resource "aws_kms_key" "worker_kms_key" {
  description              = "Worker Boundary KMS Key"
  customer_master_key_spec = local.kms.worker.master_key_spec
  is_enabled               = local.kms.worker.is_enabled
  enable_key_rotation      = local.kms.worker.enable_key_rotation

  tags = {
    Name = local.kms.worker.name
  }

}

resource "aws_kms_key" "recovery_kms_key" {
  description              = "Recovery Boundary KMS Key"
  customer_master_key_spec = local.kms.recovery.master_key_spec
  is_enabled               = local.kms.recovery.is_enabled
  enable_key_rotation      = local.kms.recovery.enable_key_rotation

  tags = {
    Name = local.kms.recovery.name
  }

}

