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

variable "elasticsearch" {
  type = object({
    name = optional(string)
    master = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number)
    }))
    data = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number)
    }))
    kibana = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
    }))
  })
  description = "Elasticsearch cluster configuration"
}