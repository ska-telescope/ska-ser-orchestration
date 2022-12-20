locals {
  configuration = merge(var.configuration, {
    flavor            = var.defaults.flavor
    image             = var.defaults.image
    availability_zone = var.defaults.availability_zone
    network           = var.defaults.network
    keypair           = var.defaults.keypair
    jump_host         = var.defaults.jump_host
  })
}