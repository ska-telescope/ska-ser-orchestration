module "boundary_controller" {
  source   = "../aws-instance"
  defaults = var.defaults.controller
  providers = {
    aws = aws
  }

  configuration = {
    name                 = var.boundary.controller.name
    instance_type        = var.boundary.controller.instance_type
    iam_instance_profile = aws_iam_instance_profile.controller.name
    ami                  = var.boundary.controller.ami
    availability_zone    = var.boundary.controller.availability_zone
    subnet_id            = var.boundary.controller.subnet_id
    security_groups      = []
    keypair              = var.boundary.controller.keypair
    jump_host            = var.boundary.controller.jump_host
  }

  depends_on = [aws_iam_instance_profile.controller]
}