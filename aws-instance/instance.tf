locals {
  user = "ubuntu" # TODO: Get from image metadata
}

resource "aws_network_interface" "net" {
  subnet_id = local.configuration.subnet_id

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "instance" {
  ami                   = local.configuration.ami # us-west-2
  instance_type         = local.configuration.instance_type
  iam_instance_profile  = local.configuration.iam_instance_profile
  key_name              = local.configuration.keypair
  
  network_interface {
    network_interface_id = aws_network_interface.net.id
    device_index         = 0
  }

  tags = {
    Name = local.configuration.name
  }
}