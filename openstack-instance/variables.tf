variable "python" {
  type        = string
  default     = "python3"
  description = "Override by setting TF_VAR_python environment variable"
}

variable "defaults" {
  type = object({
    availability_zone   = string
    flavor              = string
    image               = string
    keypair             = string
    network             = string
    jump_host           = optional(string)
    floating_ip_network = optional(string)
    vpn_cidr_blocks     = optional(list(string))
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
    create_security_group = optional(bool, true)
    security_groups       = optional(list(string), [])
    keypair               = optional(string)
    jump_host             = optional(string)
    metadata              = optional(map(string), {})
    port_security_enabled = optional(bool, true)
    volumes = optional(list(object({
      name        = string
      size        = number
      mount_point = string
    })), [])
    applications       = optional(list(string), [])
    create_floating_ip = optional(bool)
    floating_ip = optional(object({
      create  = optional(bool)
      address = optional(string)
      network = optional(string)
    }))
  })
  description = "Instance configuration"
}