variable "defaults" {
  type = object({
    availability_zone = string
    flavor            = string
    jump_host         = string
    image             = string
    keypair           = string
    network           = string
  })
  description = "Set of default values used when creating OpenStack instances"
}

variable "configuration" {
  type = object({
    name                  = string
    flavor                = optional(string)
    image                 = optional(string)
    availability_zone     = optional(string)
    network               = optional(string)
    create_security_group = optional(bool)
    security_groups       = optional(list(string))
    keypair               = optional(string)
    jump_host             = optional(string)
    volumes = optional(list(object({
      name        = string
      size        = number
      mount_point = string
    })))
  })
  description = "Instance configuration"
}