output "instance" {
  description = "Instance state"
  value = {
    id            = aws_instance.instance.id
    ami           = local.configuration.ami
    user          = local.user
    security_groups = local.configuration.security_groups
  }
}
