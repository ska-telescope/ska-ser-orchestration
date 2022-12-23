locals {
  configuration = merge(var.configuration, {
    flavor            = coalesce(var.configuration.flavor, var.defaults.flavor)
    image             = coalesce(var.configuration.image, var.defaults.image)
    availability_zone = coalesce(var.configuration.availability_zone, var.defaults.availability_zone)
    network           = coalesce(var.configuration.network, var.defaults.network)
    keypair           = coalesce(var.configuration.keypair, var.defaults.keypair)
    jump_host         = coalesce(var.configuration.jump_host, var.defaults.jump_host)
  })
}