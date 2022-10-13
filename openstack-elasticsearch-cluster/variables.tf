variable "defaults" {
  type = object({
    availability_zone   = string
    flavor              = string
    jump_host           = string
    image               = string
    keypair             = string
    network             = string
    floating_ip_network = optional(string)
  })
  description = "Set of default values used when creating OpenStack instances"
}

variable "elasticsearch" {
  type = object({
    name = optional(string)
    master = optional(object({
      name               = optional(string)
      size               = optional(number)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      data_volume_size   = optional(number)
      docker_volume_size = optional(number)
      roles              = optional(list(string))
    }))
    data = optional(object({
      name               = optional(string)
      size               = optional(number)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      data_volume_size   = optional(number)
      docker_volume_size = optional(number)
      roles              = optional(list(string))
    }))
    kibana = optional(object({
      name               = optional(string)
      size               = optional(number)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      docker_volume_size = optional(number)
    }))
    loadbalancer = optional(object({
      deploy             = optional(bool)
      name               = optional(string)
      flavor             = optional(string)
      image              = optional(string)
      availability_zone  = optional(string)
      network            = optional(string)
      keypair            = optional(string)
      jump_host          = optional(string)
      docker_volume_size = optional(number)
      floating_ip = optional(object({
        create  = optional(bool)
        address = optional(string)
        network = optional(string)
      }))
    }))
  })
  description = "Elasticsearch cluster configuration"
}