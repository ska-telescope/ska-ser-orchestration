variable "defaults" {
  type = object({
    controller = object({
      name              = string
      availability_zone = string
      instance_type     = string
      ami               = string
      vpc_id            = string
      keypair           = string
      subnet_id         = string
      jump_host         = optional(string)
      vpn_cidr_blocks   = optional(list(string))
    })
    database = object({
      db_name                 = string
      db_subnet_group_name    = optional(string)
      db_subnets              = optional(list(string))
      allocated_storage       = string
      instance_class          = string
      engine                  = string
      engine_version          = string
      username                = string
      password                = string
      parameter_group_name    = optional(string)
      skip_final_snapshot     = optional(bool,true)
    })
  })
}

variable "boundary" {
  type = object({
    name = optional(string, "boundary")
    controller = optional(object({
      name              = optional(string, "controller")
      instance_type     = optional(string)
      ami               = optional(string)
      availability_zone = optional(string)
      subnet_id         = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      roles             = optional(list(string), ["controller"])
    }))
    database = optional(object({
      db_name                 = optional(string, "boundary")
      db_subnet_group_name    = optional(string)
      db_subnets              = optional(list(string), [])
      allocated_storage       = optional(string)
      instance_class          = optional(string)
      engine                  = optional(string)
      engine_version          = optional(string)
      username                = optional(string)
      password                = optional(string)
      parameter_group_name    = optional(string)
      skip_final_snapshot     = optional(bool,true)
      security_groups         = optional(list(string), [])
      
    }))
  })
}

