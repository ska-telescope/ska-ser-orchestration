module "boundary_controller" {
  source   = "../aws-instance"
  defaults = var.defaults
  providers = {
    aws = aws
  }

  configuration = {
    name              = join("-", [var.boundary.name, var.boundary.controller.name])
    instance_type     = var.boundary.controller.instance_type
    ami               = var.boundary.controller.ami
    availability_zone = var.boundary.controller.availability_zone
    subnet_id         = var.boundary.controller.subnet_id
    security_groups   = []
    keypair           = var.boundary.controller.keypair
    jump_host         = var.boundary.controller.jump_host
  }
}