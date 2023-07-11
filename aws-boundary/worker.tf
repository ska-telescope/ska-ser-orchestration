module "boundary_worker" {
  source   = "../aws-instance"
  defaults = var.defaults.worker
  providers = {
    aws = aws
  }

  configuration = {
    name                 = var.boundary.worker.name
    instance_type        = var.boundary.worker.instance_type
    iam_instance_profile = aws_iam_instance_profile.worker.name
    ami                  = var.boundary.worker.ami
    availability_zone    = var.boundary.worker.availability_zone
    subnet_id            = var.boundary.worker.subnet_id
    security_groups      = []
    keypair              = var.boundary.worker.keypair
    jump_host            = var.boundary.worker.jump_host
  }

  depends_on = [aws_iam_instance_profile.worker]
}