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
    name = optional(string, "ceph")
    master = optional(object({
      name              = optional(string, "master")
      size              = optional(number, 0)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number, 20)
      wal_volume_size   = optional(number, 20)
    }))
    worker = optional(object({
      name              = optional(string, "worker")
      size              = optional(number, 0)
      flavor            = optional(string)
      image             = optional(string)
      availability_zone = optional(string)
      network           = optional(string)
      keypair           = optional(string)
      jump_host         = optional(string)
      data_volume_size  = optional(number, 20)
      wal_volume_size   = optional(number, 20)
    }))
  })
  description = "Ceph cluster configuration"
}