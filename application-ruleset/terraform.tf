terraform {
  required_version = "~>1.3.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>1.49.0"
    }
  }
}