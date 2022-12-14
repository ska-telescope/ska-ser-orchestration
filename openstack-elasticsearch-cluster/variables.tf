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

variable "elasticsearch" {
  type = object({
    name = optional(string, "elasticsearch")
    master = optional(object({
      name               = optional(string, "master")
      size               = optional(number, 3)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      data_volume_size   = optional(number, 20)
      docker_volume_size = optional(number, 20)
      roles              = optional(list(string), ["master"])
    }))
    data = optional(object({
      name               = optional(string, "data")
      size               = optional(number, 5)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      data_volume_size   = optional(number, 250)
      docker_volume_size = optional(number, 20)
      roles              = optional(list(string), ["data"])
    }))
    kibana = optional(object({
      name               = optional(string, "kibana")
      size               = optional(number, 1)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      docker_volume_size = optional(number, 20)
    }))
    loadbalancer = optional(object({
      deploy             = optional(bool, true)
      name               = optional(string, "loadbalancer")
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      docker_volume_size = optional(number, 20)
      floating_ip = optional(object({
        create  = optional(bool)
        address = optional(string)
        network = optional(string)
      }), {})
    }))
  })
  description = "Elasticsearch cluster configuration"
}