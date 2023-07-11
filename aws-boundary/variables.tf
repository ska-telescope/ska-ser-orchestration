variable "defaults" {
  type = object({
    controller = object({
      name                 = string
      availability_zone    = string
      instance_type        = string
      iam_instance_profile = optional(string)
      ami                  = string
      keypair              = string
      subnet_id            = string
      jump_host            = optional(string)
      vpn_cidr_blocks      = optional(list(string))
    })
    worker = object({
      name                 = string
      availability_zone    = string
      instance_type        = string
      iam_instance_profile = optional(string)
      ami                  = string
      keypair              = string
      subnet_id            = string
      jump_host            = optional(string)
      vpn_cidr_blocks      = optional(list(string))
    })
    database = object({
      identifier           = string
      db_name              = string
      db_subnet_group_name = optional(string)
      db_subnets           = optional(list(string))
      allocated_storage    = string
      instance_class       = string
      engine               = string
      engine_version       = string
      username             = string
      password             = string
      parameter_group_name = optional(string)
      skip_final_snapshot  = optional(bool, true)
    })
    kms = object({
      name                = string
      master_key_spec     = string
      is_enabled          = optional(bool, true)
      enable_key_rotation = optional(bool, true)
    })
    loadbalancer = object({
      name                       = string
      certificate_arn            = optional(string)
      environment                = optional(string)
      internal                   = bool
      load_balancer_type         = string
      additional_security_groups = optional(list(string))
      subnets                    = list(string)
      enable_deletion_protection = optional(bool, true)
    })
  })
}

variable "boundary" {
  type = object({
    name = optional(string, "boundary")
    controller = optional(object({
      name                 = optional(string, "controller")
      instance_type        = optional(string)
      iam_instance_profile = optional(string)
      ami                  = optional(string)
      availability_zone    = optional(string)
      subnet_id            = optional(string)
      keypair              = optional(string)
      jump_host            = optional(string)
      roles                = optional(list(string), ["controller"])
    }))
    worker = optional(object({
      name                 = optional(string, "controller")
      instance_type        = optional(string)
      iam_instance_profile = optional(string)
      ami                  = optional(string)
      availability_zone    = optional(string)
      subnet_id            = optional(string)
      keypair              = optional(string)
      jump_host            = optional(string)
      roles                = optional(list(string), ["controller"])
    }))
    database = optional(object({
      identifier           = optional(string)
      db_name              = optional(string, "boundary")
      db_subnet_group_name = optional(string)
      db_subnets           = optional(list(string), [])
      allocated_storage    = optional(string)
      instance_class       = optional(string)
      engine               = optional(string)
      engine_version       = optional(string)
      username             = optional(string)
      password             = optional(string)
      parameter_group_name = optional(string)
      skip_final_snapshot  = optional(bool, true)
      security_groups      = optional(list(string), [])

    }))
    kms = optional(object({
      name                = optional(string)
      master_key_spec     = optional(string)
      is_enabled          = optional(bool, true)
      enable_key_rotation = optional(bool, true)
    }))
    loadbalancer = optional(object({
      name                       = optional(string)
      certificate_arn            = optional(string)
      environment                = optional(string)
      internal                   = optional(bool, true)
      load_balancer_type         = optional(string)
      additional_security_groups = optional(list(string))
      subnets                    = optional(list(string))
      enable_deletion_protection = optional(bool, true)
    }))
  })
}

