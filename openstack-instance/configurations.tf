locals {
  configuration = defaults(var.configuration, {
    flavor                = var.defaults.flavor
    image                 = var.defaults.image
    availability_zone     = var.defaults.availability_zone
    network               = var.defaults.network
    create_security_group = true
    security_groups       = ""
    keypair               = var.defaults.keypair
    jump_host             = var.defaults.jump_host
    volumes               = {}
  })

  ssh_keys_directory = "./keys"
}