variable "defaults" {
  type = object({
    availability_zone    = string
    instance_type        = string
    iam_instance_profile = optional(string)
    ami                  = string
    keypair              = string
    subnet_id            = string
    jump_host            = optional(string)
    elastic_ip_subnet_id = optional(string)
    vpn_cidr_blocks      = optional(list(string))
  })
  description = "Set of default values used when creating AWS instances"
}

variable "configuration" {
  type = object({
    name                     = string
    instance_type            = optional(string)
    iam_instance_profile     = optional(string)
    ami                      = optional(string)
    availability_zone        = optional(string)
    subnet_id                = optional(string)
    create_security_group    = optional(bool, true)
    security_groups          = optional(list(string), [])
    external_security_groups = optional(list(string), [])
    keypair                  = optional(string)
    jump_host                = optional(string)
    metadata                 = optional(map(string), {})
    create_port              = optional(bool, false)
    fixed_ip                 = optional(string)
    port_security_enabled    = optional(bool, true)
    volumes = optional(list(object({
      name        = string
      size        = number
      mount_point = string
    })), [])
    applications      = optional(list(string), [])
    create_elastic_ip = optional(bool)
    elastic_ip = optional(object({
      create    = optional(bool)
      address   = optional(string)
      subnet_id = optional(string)
    }))
  })
  description = "Instance configuration"
}
