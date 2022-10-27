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

variable "ceph" {
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
      wal_volume_size   = optional(number)
    }))
    worker = optional(object({
      name              = optional(string)
      size              = optional(number)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number)
      wal_volume_size   = optional(number)
    }))
  })
  description = "Ceph cluster configuration"
}