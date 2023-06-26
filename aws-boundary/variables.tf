variable "defaults" {
  type = object({
    availability_zone   = string
    instance_type       = string
    ami                 = string
    vpc_id              = string
    keypair             = string
    subnet_id           = string
    jump_host           = optional(string)
    vpn_cidr_blocks     = optional(list(string))
  })
  description = "Set of default values used when creating AWS instances"
}

variable "boundary" {
  type = object({
    name = optional(string, "boundary")
    controller = optional(object({
      name               = optional(string, "controller")
      instance_type      = optional(string)
      ami                = optional(string)
      availability_zone  = optional(string)
      subnet_id          = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      roles              = optional(list(string), ["controller"])
    }))
  })
}

