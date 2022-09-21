variable "applications" {
  type        = list(string)
  default     = []
  description = "Set of application names to get the security group rules"
}

variable "networks" {
  type        = list(string)
  default     = []
  description = "List of networks to use as target (source or destination)"
}